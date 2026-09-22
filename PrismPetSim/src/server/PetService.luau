--!strict
-- Pet equip / unequip / fusion / crystallization (levelling).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local PetDatabase = require(Shared:WaitForChild("PetDatabase"))
local RarityConfig = require(Shared:WaitForChild("RarityConfig"))
local Util = require(Shared:WaitForChild("Util"))

local DataService = require(script.Parent:WaitForChild("DataService"))
local PetModelBuilder = require(script.Parent:WaitForChild("PetModelBuilder"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local EquipPet = Remotes:WaitForChild("EquipPet") :: RemoteEvent
local FusePets = Remotes:WaitForChild("FusePets") :: RemoteEvent
local LevelUpPet = Remotes:WaitForChild("LevelUpPet") :: RemoteEvent

local PetService = {}

-- Track spawned follower models per player
local followers: { [number]: { Model } } = {}

local function clearFollowers(player: Player)
	local list = followers[player.UserId]
	if not list then
		return
	end
	for _, m in list do
		m:Destroy()
	end
	followers[player.UserId] = {}
end

local function spawnFollowers(player: Player)
	clearFollowers(player)
	local data = DataService.get(player)
	local character = player.Character
	if not data or not character then
		return
	end

	local slots = 0
	for _, pet in data.pets do
		if pet.equipped then
			slots += 1
			if slots > Config.MAX_PET_SLOTS then
				break
			end
			local offset = Vector3.new((slots - (Config.MAX_PET_SLOTS + 1) / 2) * 3, 0, -4)
			local model = PetModelBuilder.spawnFollower(pet.petId, character, offset)
			if model then
				table.insert(followers[player.UserId] :: any, model)
			end
		end
	end
end

-- Total equipped power multiplier for this player
function PetService.getPowerMultiplier(player: Player): number
	local data = DataService.get(player)
	if not data then
		return 1
	end
	local total = 1
	local slots = 0
	for _, pet in data.pets do
		if pet.equipped then
			slots += 1
			if slots > Config.MAX_PET_SLOTS then
				break
			end
			local def = PetDatabase.get(pet.petId)
			if def then
				local rarityInfo = RarityConfig.get(def.rarity :: any)
				local levelBonus = 1 + (pet.level - 1) * 0.05
				local fusionBonus = 1 + pet.fusionStars * Config.FUSION_RESULT_BONUS
				total += def.basePower * rarityInfo.statBase * levelBonus * fusionBonus
			end
		end
	end
	return total
end

-- Luck multiplier from equipped pets (affects hatching)
function PetService.getLuckMultiplier(player: Player): number
	local data = DataService.get(player)
	if not data then
		return 1
	end
	local luck = 1 + data.rebirths * Config.REBIRTH_LUCK_BONUS
	-- lumenowl passive: +15% luck
	for _, pet in data.pets do
		if pet.equipped and pet.petId == "lumenowl" then
			luck += 0.15
		end
	end
	return luck
end

local function handleEquip(player: Player, uid: unknown)
	if typeof(uid) ~= "string" then
		return
	end
	local data = DataService.get(player)
	if not data then
		return
	end
	local pet = DataService.findPet(player, uid :: string)
	if not pet then
		return
	end

	if pet.equipped then
		pet.equipped = false
	else
		-- count equipped
		local equippedCount = 0
		for _, p in data.pets do
			if p.equipped then
				equippedCount += 1
			end
		end
		if equippedCount >= Config.MAX_PET_SLOTS then
			DataService.notify(player, "Слоты петей заняты! Сними одного.", true)
			return
		end
		pet.equipped = true
	end

	DataService.push(player, "pets", data.pets)
	spawnFollowers(player)
end

local function handleFuse(player: Player, uidA: unknown, uidB: unknown)
	if typeof(uidA) ~= "string" or typeof(uidB) ~= "string" then
		return
	end
	if not Config.FUSION_ENABLED then
		return
	end
	if uidA == uidB then
		DataService.notify(player, "Нужны два разных петя одного вида.", true)
		return
	end

	local data = DataService.get(player)
	if not data then
		return
	end

	local petA = DataService.findPet(player, uidA :: string)
	local petB = DataService.findPet(player, uidB :: string)
	if not petA or not petB then
		return
	end
	if petA.petId ~= petB.petId then
		DataService.notify(player, "Сливать можно только одинаковых петей!", true)
		return
	end

	local def = PetDatabase.get(petA.petId)
	if not def then
		return
	end
	local rarityInfo = RarityConfig.get(def.rarity :: any)
	if petA.fusionStars >= rarityInfo.fusionStarsMax then
		DataService.notify(player, "Достигнут максимум звёзд слияния!", true)
		return
	end

	-- Pet A absorbs pet B
	petA.fusionStars += 1
	-- Transfer some XP
	petA.xp += math.floor(petB.xp * 0.5)
	-- Keep higher level
	if petB.level > petA.level then
		petA.level = petB.level
	end
	-- Remove B
	DataService.removePet(player, uidB :: string)
	DataService.push(player, "pets", data.pets)
	DataService.notify(player, string.format("Слияние! %s стал ★%d", def.name, petA.fusionStars))
	spawnFollowers(player)
end

local function handleLevelUp(player: Player, uid: unknown)
	if typeof(uid) ~= "string" then
		return
	end
	local data = DataService.get(player)
	if not data then
		return
	end
	local pet = DataService.findPet(player, uid :: string)
	if not pet then
		return
	end
	if pet.level >= Config.MAX_PET_LEVEL then
		DataService.notify(player, "Максимальный уровень!", true)
		return
	end

	local cost = math.floor(Util.xpForLevel(pet.level, Config.XP_BASE, Config.XP_CURVE_BASE) * 2)
	if data.crystals < cost then
		DataService.notify(player, ("Нужно %d кристаллов"):format(cost), true)
		return
	end

	data.crystals -= cost
	pet.level += 1
	pet.xp = 0
	DataService.push(player, "crystals", data.crystals)
	DataService.push(player, "pets", data.pets)
	DataService.notify(player, string.format("Уровень %d!", pet.level))
	spawnFollowers(player)
end

function PetService.init()
	EquipPet.OnServerEvent:Connect(handleEquip)
	FusePets.OnServerEvent:Connect(handleFuse)
	LevelUpPet.OnServerEvent:Connect(handleLevelUp)

	-- Respawn followers when character spawns
	Players.PlayerAdded:Connect(function(player)
		followers[player.UserId] = {}
		player.CharacterAdded:Connect(function()
			task.wait(1)
			spawnFollowers(player)
		end)
	end)

	Players.PlayerRemoving:Connect(function(player)
		clearFollowers(player)
		followers[player.UserId] = nil
	end)
end

PetService.spawnFollowers = spawnFollowers

return PetService
