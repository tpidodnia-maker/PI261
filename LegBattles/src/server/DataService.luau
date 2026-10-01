--!strict
-- Player data: kills, wins, xp, owned/equipped shoes.

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local DataChanged = Remotes:WaitForChild("DataChanged") :: RemoteEvent
local Notify = Remotes:WaitForChild("Notify") :: RemoteEvent

local DataService = {}

export type PlayerData = {
	kills: number,
	wins: number,
	xp: number,
	ownedShoes: { string },
	equippedShoe: string,
	joinedAt: number,
}

local cache: { [number]: PlayerData } = {}
local store = nil

local function defaultData(): PlayerData
	return {
		kills = Config.STARTING_KILLS,
		wins = 0,
		xp = 0,
		ownedShoes = { "sneakers" },
		equippedShoe = "sneakers",
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
		warn("[LegBattles] DataStore unavailable:", result)
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
		end
	end
	if not data then
		data = defaultData()
	end
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
		warn("[LegBattles] Save failed:", player.Name, err)
	end
end

function DataService.saveAll()
	for _, player in game:GetService("Players"):GetPlayers() do
		DataService.save(player)
	end
end

function DataService.push(player: Player, key: string, value: any)
	DataChanged:FireClient(player, key, value)
end

function DataService.notify(player: Player, message: string, isError: boolean?)
	Notify:FireClient(player, message, isError == true)
end

-- leaderstats sync
function DataService.syncLeaderstats(player: Player)
	local data = cache[player.UserId]
	if not data then
		return
	end
	local ls = player:FindFirstChild("leaderstats")
	if not ls then
		ls = Instance.new("Folder")
		ls.Name = "leaderstats"
		ls.Parent = player
	end
	local function set(name: string, value: any)
		local v = ls:FindFirstChild(name)
		if not v then
			v = Instance.new("IntValue")
			v.Name = name
			v.Parent = ls
		end
		(v :: IntValue).Value = value
	end
	set("Kills", data.kills)
	set("Wins", data.wins)
end

function DataService.addKill(player: Player)
	local data = cache[player.UserId]
	if not data then
		return
	end
	data.kills += 1
	data.xp += Config.XP_PER_KILL
	DataService.push(player, "kills", data.kills)
	DataService.push(player, "xp", data.xp)
	DataService.syncLeaderstats(player)
end

function DataService.addWin(player: Player)
	local data = cache[player.UserId]
	if not data then
		return
	end
	data.wins += 1
	DataService.push(player, "wins", data.wins)
	DataService.syncLeaderstats(player)
end

function DataService.addXP(player: Player, amount: number)
	local data = cache[player.UserId]
	if not data then
		return
	end
	data.xp += amount
	DataService.push(player, "xp", data.xp)
end

function DataService.ownsShoe(player: Player, shoeId: string): boolean
	local data = cache[player.UserId]
	if not data then
		return false
	end
	return table.find(data.ownedShoes, shoeId) ~= nil
end

function DataService.grantShoe(player: Player, shoeId: string)
	local data = cache[player.UserId]
	if not data then
		return
	end
	if not table.find(data.ownedShoes, shoeId) then
		table.insert(data.ownedShoes, shoeId)
		DataService.push(player, "ownedShoes", data.ownedShoes)
	end
end

function DataService.setEquippedShoe(player: Player, shoeId: string)
	local data = cache[player.UserId]
	if not data then
		return
	end
	data.equippedShoe = shoeId
	DataService.push(player, "equippedShoe", shoeId)
end

return DataService
