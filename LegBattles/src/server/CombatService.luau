--!strict
-- Kick combat: hitbox, knockback, damage, charge.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Util = require(Shared:WaitForChild("Util"))
local ShoeDatabase = require(Shared:WaitForChild("ShoeDatabase"))

local DataService = require(script.Parent:WaitForChild("DataService"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Kick = Remotes:WaitForChild("Kick") :: RemoteEvent
local ChargeKick = Remotes:WaitForChild("ChargeKick") :: RemoteEvent
local Block = Remotes:WaitForChild("Block") :: RemoteEvent

local CombatService = {}

export type CombatState = {
	lastKick: number,
	charging: boolean,
	chargeStart: number,
	blockUntil: number,
	invulnUntil: number,
	stunUntil: number,
	dashUntil: number,
	flyUntil: number,
}

local states: { [number]: CombatState } = {}

local function getState(player: Player): CombatState
	local s = states[player.UserId]
	if not s then
		s = {
			lastKick = 0,
			charging = false,
			chargeStart = 0,
			blockUntil = 0,
			invulnUntil = 0,
			stunUntil = 0,
			dashUntil = 0,
			flyUntil = 0,
		}
		states[player.UserId] = s
	end
	return s
end

function CombatService.getState(player: Player): CombatState
	return getState(player)
end

local function getEquippedShoe(player: Player): ShoeDatabase.ShoeDef
	local data = DataService.get(player)
	local id = data and data.equippedShoe or "sneakers"
	return ShoeDatabase.get(id) or (ShoeDatabase.get("sneakers") :: any)
end

-- Find players in front of attacker within range
local function findTargets(attacker: Player, range: number): { Player }
	local char = attacker.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then
		return {}
	end
	local forward = root.CFrame.LookVector
	local targets = {}
	for _, other in Players:GetPlayers() do
		if other == attacker then
			continue
		end
		local otherChar = other.Character
		local otherRoot = otherChar and otherChar:FindFirstChild("HumanoidRootPart")
		local hum = otherChar and otherChar:FindFirstChildOfClass("Humanoid")
		if not otherRoot or not hum or hum.Health <= 0 then
			continue
		end
		local toTarget = otherRoot.Position - root.Position
		if toTarget.Magnitude > range then
			continue
		end
		-- angle check (60 degree cone)
		local angle = math.acos(math.clamp(forward:Dot(toTarget.Unit), -1, 1))
		if angle < math.rad(45) then
			table.insert(targets, other)
		end
	end
	return targets
end

local function applyKick(attacker: Player, target: Player, charged: boolean)
	local state = getState(attacker)
	local shoe = getEquippedShoe(attacker)

	local attChar = attacker.Character
	local tarChar = target.Character
	local attRoot = attChar and attChar:FindFirstChild("HumanoidRootPart")
	local tarRoot = tarChar and tarChar:FindFirstChild("HumanoidRootPart")
	local tarHum = tarChar and tarChar:FindFirstChildOfClass("Humanoid")
	if not attRoot or not tarRoot or not tarHum or tarHum.Health <= 0 then
		return
	end

	local tarState = getState(target)
	if os.clock() < tarState.invulnUntil then
		return
	end

	-- Direction
	local dir = Util.flatDir(attRoot.Position, tarRoot.Position)

	-- Backstab check: target facing away from attacker
	local tarLook = tarRoot.CFrame.LookVector
	local backstab = tarLook:Dot(dir) > 0.3

	-- Charge bonus
	local kb = Config.BASE_KNOCKBACK * shoe.knockbackMult
	local dmg = Config.KICK_DAMAGE
	if charged then
		kb *= Config.CHARGE_KNOCKBACK_MULT
		dmg *= 1.5
	end

	-- Jump kick bonus
	local attHum = attChar:FindFirstChildOfClass("Humanoid")
	local inAir = attHum and attHum.FloorMaterial == Enum.Material.Air
	if inAir then
		kb *= (1 + Config.JUMP_KICK_BONUS)
	end

	-- Backstab
	if backstab then
		dmg *= Config.BACKSTAB_MULT
		kb *= 1.2
	end

	-- Block reduces knockback
	if os.clock() < tarState.blockUntil then
		kb *= 0.5
	end

	-- Stun (freeze shoe)
	if shoe.ability.type == "freeze" then
		tarState.stunUntil = os.clock() + (shoe.ability.duration or 1)
	end

	-- Magnet: pull target toward attacker
	if shoe.ability.type == "magnet" then
		local pullDir = Util.flatDir(tarRoot.Position, attRoot.Position)
		tarRoot.AssemblyLinearVelocity = pullDir * 30 + Vector3.new(0, 10, 0)
	end

	-- Apply knockback
	local kbVec = dir * kb + Vector3.new(0, kb * 0.4, 0)
	tarRoot.AssemblyLinearVelocity = kbVec

	-- Damage
	tarHum:TakeDamage(dmg)

	-- XP for kick
	DataService.addXP(attacker, Config.XP_PER_KICK)

	-- Notify both
	Remotes:WaitForChild("DataChanged"):FireClient(attacker, "KICK_LANDED", {
		target = target.Name,
		damage = dmg,
		crit = backstab or charged,
	})
	Remotes:WaitForChild("DataChanged"):FireClient(target, "KICKED_BY", {
		attacker = attacker.Name,
		damage = dmg,
	})
end

local function handleKick(player: Player)
	local state = getState(player)
	local now = os.clock()

	if now < state.stunUntil then
		return
	end

	local cd = Config.KICK_COOLDOWN
	if state.charging then
		-- release charged kick
		local held = now - state.chargeStart
		state.charging = false
		if held < Config.CHARGE_TIME then
			-- too early: treat as normal kick
		else
			cd = Config.CHARGE_COOLDOWN
		end
	end

	if now - state.lastKick < cd then
		return
	end
	state.lastKick = now

	local charged = (now - state.chargeStart) >= Config.CHARGE_TIME and state.chargeStart > 0
	state.chargeStart = 0

	local targets = findTargets(player, Config.KICK_RANGE)
	for _, target in targets do
		applyKick(player, target, charged)
	end

	-- Tell client to play kick anim
	Remotes:WaitForChild("DataChanged"):FireClient(player, "KICK_SWING", { charged = charged })
end

local function handleChargeStart(player: Player)
	local state = getState(player)
	if state.charging then
		return
	end
	if os.clock() - state.lastKick < Config.KICK_COOLDOWN then
		return
	end
	state.charging = true
	state.chargeStart = os.clock()
end

local function handleBlock(player: Player)
	local state = getState(player)
	if os.clock() < state.blockUntil then
		return
	end
	local shoe = getEquippedShoe(player)
	if shoe.ability.type ~= "block" and shoe.ability.type ~= "all" then
		return
	end
	state.blockUntil = os.clock() + 1.5
	Remotes:WaitForChild("AbilityReady"):FireClient(player, "block", shoe.ability.cooldown)
	Remotes:WaitForChild("DataChanged"):FireClient(player, "BLOCK_ON", {})
end

function CombatService.getShoe(player: Player): ShoeDatabase.ShoeDef
	return getEquippedShoe(player)
end

function CombatService.init()
	Kick.OnServerEvent:Connect(function(player)
		task.spawn(handleKick, player)
	end)
	ChargeKick.OnServerEvent:Connect(handleChargeStart)
	Block.OnServerEvent:Connect(handleBlock)

	Players.PlayerRemoving:Connect(function(player)
		states[player.UserId] = nil
	end)

	-- Auto-regen loop
	task.spawn(function()
		while true do
			task.wait(1)
			local now = os.clock()
			for _, player in Players:GetPlayers() do
				local char = player.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if hum and hum.Health > 0 and hum.Health < Config.MAX_HP then
					local state = getState(player)
					if now - state.lastKick >= Config.REGEN_DELAY then
						hum.Health = math.min(Config.MAX_HP, hum.Health + Config.REGEN_AMOUNT)
					end
				end
			end
		end
	end)
end

-- Expose for AbilityService
CombatService.findTargets = findTargets
CombatService.applyKick = applyKick

return CombatService
