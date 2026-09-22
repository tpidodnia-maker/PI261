--!strict
-- Rebirth: reset progress for permanent multipliers.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))

local DataService = require(script.Parent:WaitForChild("DataService"))
local PetService = require(script.Parent:WaitForChild("PetService"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Rebirth = Remotes:WaitForChild("Rebirth") :: RemoteEvent

local RebirthService = {}

function RebirthService.getCost(rebirths: number): number
	return math.floor(Config.REBIRTH_BASE_COST * Config.REBIRTH_COST_GROWTH ^ rebirths)
end

local function handleRebirth(player: Player)
	local data = DataService.get(player)
	if not data then
		return
	end

	local cost = RebirthService.getCost(data.rebirths)
	if data.lumens < cost then
		DataService.notify(player, ("Для ребёрса нужно %d люменов"):format(cost), true)
		return
	end

	-- Reset
	data.rebirths += 1
	data.lumens = 0
	data.crystals = 0
	data.pets = {}
	data.unlockedZones = { "meadow" }
	data.minedTotal = 0

	DataService.push(player, "lumens", data.lumens)
	DataService.push(player, "crystals", data.crystals)
	DataService.push(player, "pets", data.pets)
	DataService.push(player, "unlockedZones", data.unlockedZones)
	DataService.push(player, "rebirths", data.rebirths)

	PetService.spawnFollowers(player)

	DataService.notify(player, string.format(
		"Ребёрс %d! +%d%% люменов, +%d%% удачи навсегда",
		data.rebirths,
		math.floor(Config.REBIRTH_LUMEN_BONUS * 100 * data.rebirths),
		math.floor(Config.REBIRTH_LUCK_BONUS * 100 * data.rebirths),
	))
end

function RebirthService.init()
	Rebirth.OnServerEvent:Connect(handleRebirth)
end

return RebirthService
