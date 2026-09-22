--!strict
-- Egg hatching: pick rarity via zone weights + luck, pick pet, grant it.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local PetDatabase = require(Shared:WaitForChild("PetDatabase"))
local Util = require(Shared:WaitForChild("Util"))

local DataService = require(script.Parent:WaitForChild("DataService"))
local PetService = require(script.Parent:WaitForChild("PetService"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Hatch = Remotes:WaitForChild("Hatch") :: RemoteEvent
local DataChanged = Remotes:WaitForChild("DataChanged") :: RemoteEvent

local HatchService = {}

local lastHatch: { [number]: number } = {}

-- Build rarity weights for the player's current best zone
local function getWeights(player: Player): { [string]: number }
	local data = DataService.get(player)
	if not data then
		return { Common = 100 }
	end
	-- Use the highest-cost unlocked zone
	local bestZone = Config.ZONES[1]
	for _, zone in Config.ZONES do
		if table.find(data.unlockedZones, zone.id) then
			if zone.cost >= bestZone.cost then
				bestZone = zone
			end
		end
	end
	return bestZone.rarityWeights
end

function HatchService.getHatchCost(player: Player): number
	local data = DataService.get(player)
	local count = data and #data.pets or 0
	local cost = Config.HATCH_BASE_COST * Config.HATCH_COST_GROWTH ^ count

	-- glacier passive: -5% hatch cost
	if data then
		for _, pet in data.pets do
			if pet.equipped and pet.petId == "glacier" then
				cost *= 0.95
			end
		end
	end

	-- rebirth discount
	if data then
		cost *= 0.95 ^ data.rebirths
	end

	return math.floor(cost)
end

local function handleHatch(player: Player)
	local data = DataService.get(player)
	if not data then
		return
	end

	-- Cooldown (anti-spam)
	local now = os.clock()
	if lastHatch[player.UserId] and now - lastHatch[player.UserId] < Config.ANIMATION_DURATION then
		return
	end
	lastHatch[player.UserId] = now

	local cost = HatchService.getHatchCost(player)
	if data.lumens < cost then
		DataService.notify(player, ("Нужно %d люменов"):format(cost), true)
		return
	end

 DataService.spendLumens(player, cost)

	-- Roll rarity with luck boosting higher tiers
	local weights = getWeights(player)
	local luck = PetService.getLuckMultiplier(player)
	local boosted: { [string]: number } = {}
	for rarity, weight in weights do
		-- luck pushes weight from lower rarities toward higher ones
		local rarityIdx = 0
		for i, r in { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Cosmic" } do
			if r == rarity then
				rarityIdx = i
				break
			end
		end
		boosted[rarity] = weight * luck ^ (rarityIdx * 0.3)
	end

	local rarity = Util.weightedPick(boosted :: any)
	if not rarity then
		rarity = "Common"
	end

	-- Pick a random pet of that rarity
	local pool = PetDatabase.byRarity(rarity :: string)
	if #pool == 0 then
		pool = PetDatabase.byRarity("Common")
	end
	local def = pool[math.random(1, #pool)]

	local pet = DataService.newPet(player, def.id)
	if not pet then
		return
	end

	-- Tell client to play hatch animation
	DataChanged:FireClient(player, "HATCH_RESULT", {
		petId = def.id,
		rarity = def.rarity,
		uid = pet.uid,
	})
	DataService.notify(player, string.format("Вылупился %s [%s]!", def.name, def.rarity))
end

function HatchService.init()
	Hatch.OnServerEvent:Connect(handleHatch)

	Players = game:GetService("Players")
	Players.PlayerRemoving:Connect(function(player)
		lastHatch[player.UserId] = nil
	end)
end

-- Fix forward-declared Players
local Players = game:GetService("Players")

return HatchService
