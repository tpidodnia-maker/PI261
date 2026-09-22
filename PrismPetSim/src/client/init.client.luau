--!strict
-- Crystalis client bootstrap.
-- Creates the HUD, wires remotes, runs the main loop.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Util = require(Shared:WaitForChild("Util"))
local PetDatabase = require(Shared:WaitForChild("PetDatabase"))
local RarityConfig = require(Shared:WaitForChild("RarityConfig"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local GetData = Remotes:WaitForChild("GetData") :: RemoteFunction
local DataChanged = Remotes:WaitForChild("DataChanged") :: RemoteEvent
local Notify = Remotes:WaitForChild("Notify") :: RemoteEvent
local Mine = Remotes:WaitForChild("Mine") :: RemoteEvent
local Hatch = Remotes:WaitForChild("Hatch") :: RemoteEvent
local EquipPet = Remotes:WaitForChild("EquipPet") :: RemoteEvent
local FusePets = Remotes:WaitForChild("FusePets") :: RemoteEvent
local UnlockZone = Remotes:WaitForChild("UnlockZone") :: RemoteEvent
local Rebirth = Remotes:WaitForChild("Rebirth") :: RemoteEvent
local LevelUpPet = Remotes:WaitForChild("LevelUpPet") :: RemoteEvent

local UIBuilder = require(script:WaitForChild("UIBuilder"))

-- Local data mirror
local data = nil :: any

-- ============ HUD ============
local hud = UIBuilder.buildHUD()

-- ============ Data sync ============
local function refreshHUD()
	if not data then
		return
	end
	hud.lumensLabel.Text = "💎 " .. Util.formatNumber(data.lumens)
	hud.crystalsLabel.Text = "🔷 " .. Util.formatNumber(data.crystals)
	hud.rebirthLabel.Text = "↻ " .. tostring(data.rebirths)

	local cost = UIBuilder.getHatchCost(data)
	hud.hatchCostLabel.Text = Util.formatNumber(cost)

	-- Zone buttons
	UIBuilder.updateZoneButtons(hud, data, function(zoneId)
		UnlockZone:FireServer(zoneId)
	end)

	-- Pet inventory
	UIBuilder.updatePetGrid(hud, data, {
		onEquip = function(uid)
			EquipPet:FireServer(uid)
		end,
		onFuse = function(uidA, uidB)
			FusePets:FireServer(uidA, uidB)
		end,
		onLevel = function(uid)
			LevelUpPet:FireServer(uid)
		end,
	})
end

-- Initial fetch
task.spawn(function()
	local ok, result = pcall(function()
		return GetData:InvokeServer()
	end)
	if ok and result then
		data = result
		refreshHUD()
	end
end)

DataChanged.OnClientEvent:Connect(function(key, value)
	if not data then
		data = {}
	end
	if key == "FULL" then
		data = value
	elseif key == "HATCH_RESULT" then
		UIBuilder.playHatchAnimation(hud, value)
		-- data.pets will also be pushed separately
	elseif key == "MINE" then
		UIBuilder.showMinePopup(hud, value)
	else
		(data :: any)[key] = value
	end
	refreshHUD()
end)

Notify.OnClientEvent:Connect(function(message, isError)
	UIBuilder.showToast(hud, message, isError)
end)

-- ============ Input ============
-- Press E near altar / H anywhere to hatch
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if input.KeyCode == Enum.KeyCode.H or input.KeyCode == Enum.KeyCode.E then
		Hatch:FireServer()
	end
end)

-- ============ Mining via clicking nodes ============
-- ClickDetector on server handles it; also send remote on tap for mobile
local function bindCrystalNodes()
	local world = workspace:FindFirstChild("CrystalisWorld")
	if not world then
		return
	end
	for _, node in world:GetChildren() do
		if node:IsA("BasePart") and node:GetAttribute("ZoneId") then
			local cd = node:FindFirstChildOfClass("ClickDetector")
			if cd and not cd:GetAttribute("Bound") then
				cd:SetAttribute("Bound", true)
				cd.MouseClick:Connect(function()
					Mine:FireServer(node:GetAttribute("ZoneId"))
				end)
			end
		end
	end
end

task.spawn(function()
	while true do
		bindCrystalNodes()
		task.wait(2)
	end
end)

-- ============ Rebirth button ============
hud.rebirthButton.MouseButton1Click:Connect(function()
	Rebirth:FireServer()
end)

-- ============ Hatch button ============
hud.hatchButton.MouseButton1Click:Connect(function()
	Hatch:FireServer()
end)

-- ============ Pet inventory toggle ============
hud.inventoryButton.MouseButton1Click:Connect(function()
	UIBuilder.toggleInventory(hud)
end)

-- ============ Zone panel toggle ============
hud.zonesButton.MouseButton1Click:Connect(function()
	UIBuilder.toggleZones(hud)
end)

-- ============ Follow character ============
task.spawn(function()
	while true do
		task.wait(0.2)
		if hud.root and player.Character then
			local hrp = player.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				-- root stays; panels are fixed. Nothing to move.
			end
		end
	end
end)

print("[Crystalis] Client loaded.")
