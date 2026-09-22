--!strict
-- Player data: load / save / autosave via DataStoreService.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Util = require(Shared:WaitForChild("Util"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local DataChanged = Remotes:WaitForChild("DataChanged") :: RemoteEvent
local Notify = Remotes:WaitForChild("Notify") :: RemoteEvent

local DataService = {}

export type PetInstance = {
	uid: string,           -- unique id for this pet instance
	petId: string,
	level: number,
	xp: number,
	fusionStars: number,   -- 0..max from fusions
	equipped: boolean,
}

export type PlayerData = {
	lumens: number,
	crystals: number,          -- generic crystal currency for levelling pets
	pets: { PetInstance },
	unlockedZones: { string },
	rebirths: number,
	minedTotal: number,
	joinedAt: number,
}

local cache: { [number]: PlayerData } = {}
local store = nil

local function generateUid(): string
	return string.format("%d_%d", os.time(), math.random(100000, 999999))
end

local function defaultData(): PlayerData
	return {
		lumens = Config.STARTING_LUMENS,
		crystals = 0,
		pets = {},
		unlockedZones = { "meadow" },
		rebirths = 0,
		minedTotal = 0,
		joinedAt = os.time(),
	}
end

function DataService.get(player: Player): PlayerData?
	return cache[player.UserId]
end

function DataService.init()
	local ok, result = pcall(function()
		return DataStoreService:GetDataStore(Config.DATASTORE_KEY)
	end)
	if ok then
		store = result
	else
		warn("[Crystalis] DataStore unavailable, running in memory-only mode:", result)
	end

	Remotes:WaitForChild("GetData").OnServerInvoke = function(player)
		return cache[player.UserId]
	end
end

function DataService.load(player: Player)
	local data: PlayerData? = nil

	if store then
		local ok, result = pcall(function()
			return (store :: any):GetAsync("u" .. player.UserId)
		end)
		if ok and typeof(result) == "table" then
			data = result
		elseif not ok then
			warn("[Crystalis] Load failed for", player.Name, result)
		end
	end

	if not data then
		data = defaultData()
	end

	-- Forward-compat: ensure all fields exist
	local def = defaultData()
	for k, v in def do
		if (data :: any)[k] == nil then
			(data :: any)[k] = v
		end
	end

	cache[player.UserId] = data
	DataChanged:FireClient(player, "FULL", data)
end

function DataService.unload(player: Player)
	DataService.save(player)
	cache[player.UserId] = nil
end

function DataService.save(player: Player)
	local data = cache[player.UserId]
	if not data or not store then
		return
	end
	local ok, err = pcall(function()
		(store :: any):SetAsync("u" .. player.UserId, data)
	end)
	if not ok then
		warn("[Crystalis] Save failed for", player.Name, err)
	end
end

function DataService.saveAll()
	for _, player in Players:GetPlayers() do
		DataService.save(player)
	end
end

-- Push a delta to the client so UI stays in sync
function DataService.push(player: Player, key: string, value: any)
	DataChanged:FireClient(player, key, value)
end

function DataService.notify(player: Player, message: string, isError: boolean?)
	Notify:FireClient(player, message, isError == true)
end

-- Convenience: add lumens with rebirth bonus
function DataService.addLumens(player: Player, amount: number)
	local data = cache[player.UserId]
	if not data then
		return
	end
	local mult = 1 + data.rebirths * Config.REBIRTH_LUMEN_BONUS
	data.lumens += math.floor(amount * mult)
	DataService.push(player, "lumens", data.lumens)
end

function DataService.spendLumens(player: Player, amount: number): boolean
	local data = cache[player.UserId]
	if not data or data.lumens < amount then
		return false
	end
	data.lumens -= amount
	DataService.push(player, "lumens", data.lumens)
	return true
end

function DataService.addCrystals(player: Player, amount: number)
	local data = cache[player.UserId]
	if not data then
		return
	end
	data.crystals += amount
	DataService.push(player, "crystals", data.crystals)
end

function DataService.newPet(player: Player, petId: string): PetInstance?
	local data = cache[player.UserId]
	if not data then
		return nil
	end
	if #data.pets >= Config.INVENTORY_CAP then
		DataService.notify(player, "Инвентарь полон! Расfusionируй лишних петей.", true)
		return nil
	end
	local pet: PetInstance = {
		uid = generateUid(),
		petId = petId,
		level = 1,
		xp = 0,
		fusionStars = 0,
		equipped = false,
	}
	table.insert(data.pets, pet)
	DataService.push(player, "pets", data.pets)
	return pet
end

function DataService.findPet(player: Player, uid: string): PetInstance?
	local data = cache[player.UserId]
	if not data then
		return nil
	end
	for _, pet in data.pets do
		if pet.uid == uid then
			return pet
		end
	end
	return nil
end

function DataService.removePet(player: Player, uid: string)
	local data = cache[player.UserId]
	if not data then
		return
	end
	for i, pet in data.pets do
		if pet.uid == uid then
			table.remove(data.pets, i)
			DataService.push(player, "pets", data.pets)
			return
		end
	end
end

return DataService
