--!strict
-- LEG BATTLES — Client bootstrap.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local ShoeDatabase = require(Shared:WaitForChild("ShoeDatabase"))
local Util = require(Shared:WaitForChild("Util"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local GetData = Remotes:WaitForChild("GetData") :: RemoteFunction
local DataChanged = Remotes:WaitForChild("DataChanged") :: RemoteEvent
local Kick = Remotes:WaitForChild("Kick") :: RemoteEvent
local ChargeKick = Remotes:WaitForChild("ChargeKick") :: RemoteEvent
local Ability = Remotes:WaitForChild("Ability") :: RemoteEvent
local Block = Remotes:WaitForChild("Block") :: RemoteEvent
local BuyShoe = Remotes:WaitForChild("BuyShoe") :: RemoteEvent
local EquipShoe = Remotes:WaitForChild("EquipShoe") :: RemoteEvent
local KillFeed = Remotes:WaitForChild("KillFeed") :: RemoteEvent
local Notify = Remotes:WaitForChild("Notify") :: RemoteEvent
local AbilityReady = Remotes:WaitForChild("AbilityReady") :: RemoteEvent

local UIBuilder = require(script:WaitForChild("UIBuilder"))

local data = nil :: any
local hud = UIBuilder.buildHUD()
local cooldowns: { [string]: number } = {}

-- ============ Data ============
task.spawn(function()
	local ok, result = pcall(function()
		return GetData:InvokeServer()
	end)
	if ok and result then
		data = result
		UIBuilder.updateHUD(hud, data)
		UIBuilder.updateShop(hud, data, function(id) BuyShoe:FireServer(id) end, function(id) EquipShoe:FireServer(id) end)
	end
end)

DataChanged.OnClientEvent:Connect(function(key, value)
	if not data then
		data = {}
	end
	if key == "FULL" then
		data = value
	elseif key == "KICK_SWING" then
		UIBuilder.playKickAnim(hud, value.charged)
	elseif key == "KICK_LANDED" then
		UIBuilder.showHitmarker(hud, value)
	elseif key == "KICKED_BY" then
		UIBuilder.showDamageFlash(hud, value)
	elseif key == "BLOCK_ON" then
		UIBuilder.showBlockFx(hud)
	elseif key == "ABILITY_FX" then
		UIBuilder.showAbilityFx(hud, value)
	else
		(data :: any)[key] = value
	end
	UIBuilder.updateHUD(hud, data)
	if key == "kills" or key == "equippedShoe" or key == "ownedShoes" then
		UIBuilder.updateShop(hud, data, function(id) BuyShoe:FireServer(id) end, function(id) EquipShoe:FireServer(id) end)
	end
end)

KillFeed.OnClientEvent:Connect(function(entry)
	UIBuilder.addKillFeed(hud, entry)
end)

Notify.OnClientEvent:Connect(function(message, isError)
	UIBuilder.showToast(hud, message, isError)
end)

AbilityReady.OnClientEvent:Connect(function(abilityId, duration)
	cooldowns[abilityId] = os.clock() + duration
	UIBuilder.updateCooldowns(hud, cooldowns)
end)

-- ============ Input ============
local chargeHeld = false

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		-- Start charging, fire kick on release handled below
		ChargeKick:FireServer()
		chargeHeld = true
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		Block:FireServer()
	elseif input.KeyCode == Enum.KeyCode.Shift then
		local shoe = data and ShoeDatabase.get(data.equippedShoe)
		if shoe then
			if shoe.ability.type == "dash" or shoe.ability.type == "phase" or shoe.ability.type == "all" then
				Ability:FireServer(shoe.ability.type)
			end
		end
	elseif input.KeyCode == Enum.KeyCode.E then
		local shoe = data and ShoeDatabase.get(data.equippedShoe)
		if shoe and (shoe.ability.type == "lightning" or shoe.ability.type == "time" or shoe.ability.type == "all") then
			Ability:FireServer(shoe.ability.type)
		end
	elseif input.KeyCode == Enum.KeyCode.F then
		local shoe = data and ShoeDatabase.get(data.equippedShoe)
		if shoe and (shoe.ability.type == "fly" or shoe.ability.type == "all") then
			Ability:FireServer("fly")
		end
	elseif input.KeyCode == Enum.KeyCode.Tab then
		UIBuilder.toggleShop(hud)
	end
end)

UserInputService.InputEnded:Connect(function(input, processed)
	if input.UserInputType == Enum.UserInputType.MouseButton1 and chargeHeld then
		chargeHeld = false
		Kick:FireServer()
	end
end)

print("[LegBattles] Client loaded.")
