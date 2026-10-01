--!strict
-- Active abilities: dash, phase, fly, lightning, time, quake.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local ShoeDatabase = require(Shared:WaitForChild("ShoeDatabase"))

local DataService = require(script.Parent:WaitForChild("DataService"))
local CombatService = require(script.Parent:WaitForChild("CombatService"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Ability = Remotes:WaitForChild("Ability") :: RemoteEvent
local AbilityReady = Remotes:WaitForChild("AbilityReady") :: RemoteEvent
local DataChanged = Remotes:WaitForChild("DataChanged") :: RemoteEvent

local AbilityService = {}

local cooldowns: { [number]: { [string]: number } } = {}

local function onCooldown(player: Player, abilityId: string): boolean
	local cd = cooldowns[player.UserId]
	if not cd then
		cd = {}
		cooldowns[player.UserId] = cd
	end
	local readyAt = cd[abilityId] or 0
	return os.clock() < readyAt
end

local function setCooldown(player: Player, abilityId: string, duration: number)
	local cd = cooldowns[player.UserId]
	if not cd then
		cd = {}
		cooldowns[player.UserId] = cd
	end
	cd[abilityId] = os.clock() + duration
	AbilityReady:FireClient(player, abilityId, duration)
end

local function getShoe(player: Player): ShoeDatabase.ShoeDef
	return CombatService.getShoe(player)
end

-- ============ Abilities ============

local function doDash(player: Player, shoe: ShoeDatabase.ShoeDef)
	if onCooldown(player, "dash") then
		return
	end
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	local dir = root.CFrame.LookVector
	root.AssemblyLinearVelocity = dir * 120 + Vector3.new(0, 20, 0)
	setCooldown(player, "dash", shoe.ability.cooldown)
	DataChanged:FireClient(player, "ABILITY_FX", { type = "dash" })
end

local function doPhase(player: Player, shoe: ShoeDatabase.ShoeDef)
	if onCooldown(player, "phase") then
		return
	end
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	local state = CombatService.getState(player)
	state.invulnUntil = os.clock() + (shoe.ability.duration or 0.5)
	state.dashUntil = os.clock() + (shoe.ability.duration or 0.5)

	-- Make character non-collidable briefly
	for _, d in char:GetDescendants() do
		if d:IsA("BasePart") then
			d.CanCollide = false
		end
	end
	task.delay(shoe.ability.duration or 0.5, function()
		if char.Parent then
			for _, d in char:GetDescendants() do
				if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then
					d.CanCollide = true
				end
			end
		end
	end)

	local dir = root.CFrame.LookVector
	root.AssemblyLinearVelocity = dir * 100 + Vector3.new(0, 10, 0)
	setCooldown(player, "phase", shoe.ability.cooldown)
	DataChanged:FireClient(player, "ABILITY_FX", { type = "phase" })
end

local function doFly(player: Player, shoe: ShoeDatabase.ShoeDef)
	if onCooldown(player, "fly") then
		return
	end
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then
		return
	end
	local state = CombatService.getState(player)
	state.flyUntil = os.clock() + (shoe.ability.duration or 3)

	-- Custom fly: enable flying via BodyVelocity-like approach
	local root = char:FindFirstChild("HumanoidRootPart")
	if root then
		local att = Instance.new("Attachment")
		att.Name = "FlyAtt"
		att.Parent = root
		local vf = Instance.new("VectorForce")
		vf.Attachment0 = att
		vf.RelativeTo = Enum.ActuatorRelativeTo.World
		vf.ApplyAtCenterOfMass = true
		vf.Force = Vector3.new(0, 200, 0) -- counteract gravity
		vf.Name = "FlyForce"
		vf.Parent = root

		task.delay(shoe.ability.duration or 3, function()
			if vf.Parent then
				vf:Destroy()
			end
			if att.Parent then
				att:Destroy()
			end
		end)
	end

	setCooldown(player, "fly", shoe.ability.cooldown)
	DataChanged:FireClient(player, "ABILITY_FX", { type = "fly", duration = shoe.ability.duration or 3 })
end

local function doLightning(player: Player, shoe: ShoeDatabase.ShoeDef)
	if onCooldown(player, "lightning") then
		return
	end
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	local targets = CombatService.findTargets(player, 30)
	local hit = 0
	for _, target in targets do
		if hit >= 3 then
			break
		end
		local tChar = target.Character
		local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
		local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
		if tHum and tRoot and tHum.Health > 0 then
			tHum:TakeDamage(35)
			local kbDir = Util_flatDir(root.Position, tRoot.Position)
			tRoot.AssemblyLinearVelocity = kbDir * 50 + Vector3.new(0, 30, 0)

			-- Lightning visual
			local beam = Instance.new("Part")
			beam.Anchored = true
			beam.CanCollide = false
			beam.Material = Enum.Material.Neon
			beam.Color = Color3.fromRGB(255, 255, 100)
			beam.Size = Vector3.new(0.5, 0.5, (tRoot.Position - root.Position).Magnitude)
			beam.CFrame = CFrame.lookAt(root.Position, tRoot.Position) * CFrame.new(0, 0, -beam.Size.Z / 2)
			beam.Parent = workspace
			game:GetService("Debris"):AddItem(beam, 0.2)

			hit += 1
		end
	end

	setCooldown(player, "lightning", shoe.ability.cooldown)
	DataChanged:FireClient(player, "ABILITY_FX", { type = "lightning", targets = hit })
end

local function doTime(player: Player, shoe: ShoeDatabase.ShoeDef)
	if onCooldown(player, "time") then
		return
	end
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	local duration = shoe.ability.duration or 2
	for _, other in Players:GetPlayers() do
		if other == player then
			continue
		end
		local oChar = other.Character
		local oHum = oChar and oChar:FindFirstChildOfClass("Humanoid")
		if oHum and oHum.Health > 0 then
			-- Slow walk speed
			local original = oHum.WalkSpeed
			oHum.WalkSpeed = original * 0.3
			local state = CombatService.getState(other)
			state.stunUntil = os.clock() + duration * 0.5
			task.delay(duration, function()
				if oHum.Parent then
					oHum.WalkSpeed = 16
				end
			end)
		end
	end

	setCooldown(player, "time", shoe.ability.cooldown)
	DataChanged:FireClient(player, "ABILITY_FX", { type = "time", duration = duration })
end

-- flatDir local helper (avoid circular require with Util)
function Util_flatDir(from: Vector3, to: Vector3): Vector3
	local d = Vector3.new(to.X - from.X, 0, to.Z - from.Z)
	if d.Magnitude < 0.001 then
		return Vector3.new(0, 0, -1)
	end
	return d.Unit
end

-- ============ Dispatch ============

local function handleAbility(player: Player, abilityType: unknown)
	if typeof(abilityType) ~= "string" then
		return
	end
	local shoe = getShoe(player)
	local t = shoe.ability.type

	-- "all" shoes can use everything
	if t ~= "all" and t ~= abilityType then
		return
	end

	if abilityType == "dash" then
		doDash(player, shoe)
	elseif abilityType == "phase" then
		doPhase(player, shoe)
	elseif abilityType == "fly" then
		doFly(player, shoe)
	elseif abilityType == "lightning" then
		doLightning(player, shoe)
	elseif abilityType == "time" then
		doTime(player, shoe)
	end
end

function AbilityService.init()
	Ability.OnServerEvent:Connect(handleAbility)

	Players.PlayerRemoving:Connect(function(player)
		cooldowns[player.UserId] = nil
	end)
end

return AbilityService
