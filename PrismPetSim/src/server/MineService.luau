--!strict
-- Mining: click crystal nodes to earn lumens + crystals.
-- Multiplied by equipped pets and zone yield.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))

local DataService = require(script.Parent:WaitForChild("DataService"))
local PetService = require(script.Parent:WaitForChild("PetService"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Mine = Remotes:WaitForChild("Mine") :: RemoteEvent

local MineService = {}

local lastMine: { [number]: number } = {}

-- Server-side validation of a mine request
local function handleMine(player: Player, zoneId: unknown)
	if typeof(zoneId) ~= "string" then
		return
	end
	local data = DataService.get(player)
	if not data then
		return
	end

	-- Cooldown
	local now = os.clock()
	if lastMine[player.UserId] and now - lastMine[player.UserId] < Config.MINE_BASE_COOLDOWN then
		return
	end
	lastMine[player.UserId] = now

	-- Zone must be unlocked
	if not table.find(data.unlockedZones, zoneId :: string) then
		DataService.notify(player, "Зона не открыта!", true)
		return
	end

	local zone = nil
	for _, z in Config.ZONES do
		if z.id == zoneId then
			zone = z
			break
		end
	end
	if not zone then
		return
	end

	-- Base yield
	local yield = Config.MINE_BASE_YIELD * zone.yieldMultiplier

	-- Pet power multiplier
	local power = PetService.getPowerMultiplier(player)
	yield *= power

	-- Crit
	local isCrit = math.random() < Config.MINE_CRIT_CHANCE
	if isCrit then
		yield *= Config.MINE_CRIT_MULTIPLIER
	end

	-- sprout passive: +20% crystal yield
	local crystalGain = math.floor(yield * 0.3)
	for _, pet in data.pets do
		if pet.equipped and pet.petId == "sprout" then
			crystalGain = math.floor(crystalGain * 1.2)
		end
	end

	data.minedTotal += 1
	DataService.addLumens(player, math.floor(yield))
	if crystalGain > 0 then
		DataService.addCrystals(player, crystalGain)
	end

	-- Feedback to client
	Remotes:WaitForChild("DataChanged"):FireClient(player, "MINE", {
		amount = math.floor(yield),
		crystals = crystalGain,
		crit = isCrit,
		zone = zoneId,
	})
end

function MineService.init()
	Mine.OnServerEvent:Connect(handleMine)

	-- Wire ClickDetectors on crystal nodes as an alternative to remote
	local world = Workspace:FindFirstChild("CrystalisWorld")
	if world then
		for _, node in world:GetChildren() do
			if node:IsA("BasePart") and node:GetAttribute("ZoneId") then
				local cd = node:FindFirstChildOfClass("ClickDetector")
				if cd then
					cd.MouseClick:Connect(function(player)
						handleMine(player, node:GetAttribute("ZoneId"))
					end)
				end
			end
		end
	end

	game:GetService("Players").PlayerRemoving:Connect(function(player)
		lastMine[player.UserId] = nil
	end)
end

return MineService
