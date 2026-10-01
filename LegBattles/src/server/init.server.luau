--!strict
-- LEG BATTLES — Server bootstrap.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))

-- Remotes
local remotes = ReplicatedStorage:FindFirstChild("Remotes")
if not remotes then
	remotes = Instance.new("Folder")
	remotes.Name = "Remotes"
	remotes.Parent = ReplicatedStorage
end
for _, name in Config.REMOTES do
	if not remotes:FindFirstChild(name) then
		local className = (name == "GetData") and "RemoteFunction" or "RemoteEvent"
		local r = Instance.new(className)
		r.Name = name
		r.Parent = remotes
	end
end

-- Services
local DataService = require(script:WaitForChild("DataService"))
local ArenaService = require(script:WaitForChild("ArenaService"))
local CombatService = require(script:WaitForChild("CombatService"))
local AbilityService = require(script:WaitForChild("AbilityService"))
local KillService = require(script:WaitForChild("KillService"))
local ShopService = require(script:WaitForChild("ShopService"))
local EventService = require(script:WaitForChild("EventService"))

ArenaService.build()
DataService.init()
CombatService.init()
AbilityService.init()
KillService.init()
ShopService.init()
EventService.init()

-- Player lifecycle
Players.PlayerAdded:Connect(function(player)
	DataService.load(player)
	player.CharacterAdded:Connect(function(char)
		KillService.onCharacterSpawn(player, char)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	DataService.unload(player)
end)

task.spawn(function()
	while true do
		task.wait(Config.AUTOSAVE_INTERVAL)
		DataService.saveAll()
	end
end)

game:BindToClose(function()
	DataService.saveAll()
	task.wait(2)
end)

print("[LegBattles] Server started.")
