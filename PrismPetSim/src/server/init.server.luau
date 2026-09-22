--!strict
-- Crystalis server bootstrap.
-- Requires all services, creates remotes, starts the loop.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))

-- Create remotes folder
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
if not Remotes then
	Remotes = Instance.new("Folder")
	Remotes.Name = "Remotes"
	Remotes.Parent = ReplicatedStorage
end

local function makeRemote(name: string, className: string): Instance
	local existing = Remotes:FindFirstChild(name)
	if existing then
		return existing
	end
	local r = Instance.new(className)
	r.Name = name
	r.Parent = Remotes
	return r
end

makeRemote("Mine", "RemoteEvent")            -- client -> server: attempt mine
makeRemote("Hatch", "RemoteEvent")           -- client -> server: hatch egg
makeRemote("EquipPet", "RemoteEvent")        -- client -> server: equip/unequip
makeRemote("FusePets", "RemoteEvent")        -- client -> server: fuse two pets
makeRemote("UnlockZone", "RemoteEvent")      -- client -> server: buy zone
makeRemote("Rebirth", "RemoteEvent")         -- client -> server: rebirth
makeRemote("LevelUpPet", "RemoteEvent")      -- client -> server: spend crystals to level pet
makeRemote("GetData", "RemoteFunction")      -- client -> server: full data snapshot
makeRemote("DataChanged", "RemoteEvent")     -- server -> client: delta update
makeRemote("Notify", "RemoteEvent")          -- server -> client: toast message

-- Require services in dependency order
local DataService = require(script:WaitForChild("DataService"))
local PetModelBuilder = require(script:WaitForChild("PetModelBuilder"))
local PetService = require(script:WaitForChild("PetService"))
local HatchService = require(script:WaitForChild("HatchService"))
local ZoneService = require(script:WaitForChild("ZoneService"))
local RebirthService = require(script:WaitForChild("RebirthService"))
local MineService = require(script:WaitForChild("MineService"))

-- Wire services
DataService.init()
PetService.init()
HatchService.init()
ZoneService.init()
RebirthService.init()
MineService.init()

-- Build a display platform in workspace if missing
local function ensureWorld()
	local ws = workspace
	if not ws:FindFirstChild("CrystalisWorld") then
		local world = Instance.new("Folder")
		world.Name = "CrystalisWorld"

		-- Spawn platform
		local plat = Instance.new("Part")
		plat.Name = "SpawnPlatform"
		plat.Size = Vector3.new(40, 1, 40)
		plat.Position = Vector3.new(0, 0.5, 0)
		plat.Anchored = true
		plat.Color = Color3.fromRGB(40, 40, 55)
		plat.Material = Enum.Material.Slate
		plat.Parent = world

		-- Hatch altar
		local altar = Instance.new("Part")
		altar.Name = "HatchAltar"
		altar.Size = Vector3.new(6, 4, 6)
		altar.Position = Vector3.new(0, 2.5, -15)
		altar.Anchored = true
		altar.Color = Color3.fromRGB(255, 220, 100)
		altar.Material = Enum.Material.Neon
		altar.Shape = Enum.PartType.Cylinder
		altar.Orientation = Vector3.new(0, 0, 90)
		altar.Parent = world

		-- Crystal nodes for each zone
		local Config2 = require(Shared:WaitForChild("Config"))
		for i, zone in Config2.ZONES do
			local node = Instance.new("Part")
			node.Name = "CrystalNode_" .. zone.id
			node.Size = Vector3.new(4, 6, 4)
			node.Position = Vector3.new(25 + i * 12, 3.5, 0)
			node.Anchored = true
			node.Color = zone.color
			node.Material = Enum.Material.Neon
			node.Shape = Enum.PartType.Ball
			node:SetAttribute("ZoneId", zone.id)
			node.Parent = world

			local clickDetector = Instance.new("ClickDetector")
			clickDetector.MaxActivationDistance = 20
			clickDetector.Parent = node
		end

		world.Parent = ws
	end
end

ensureWorld()

-- Player lifecycle
Players.PlayerAdded:Connect(function(player)
	DataService.load(player)
end)

Players.PlayerRemoving:Connect(function(player)
	DataService.unload(player)
end)

-- Autosave loop
task.spawn(function()
	while true do
		task.wait(Config.AUTOSAVE_INTERVAL)
		DataService.saveAll()
	end
end)

-- Save on server shutdown
game:BindToClose(function()
	DataService.saveAll()
	task.wait(2)
end)

print("[Crystalis] Server started.")
