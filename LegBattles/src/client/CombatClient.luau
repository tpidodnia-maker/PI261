--!strict
-- Real kick animation (limb Motor6D rotation), screen shake, hit VFX, sounds.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local CombatClient = {}

-- ============ Sounds (built-in Roblox assets) ============
local function playSound(id: string, volume: number, speed: number?)
	local sound = Instance.new("Sound")
	sound.SoundId = id
	sound.Volume = volume
	if speed then
		sound.PlaybackSpeed = speed
	end
	sound.Parent = workspace
	sound:Play()
	Debris:AddItem(sound, 3)
end

local WHOOSH = "rbxasset://sounds/swoosh.wav"
local HIT = "rbxasset://sounds/snap.mp3"
local PING = "rbxasset://sounds/electronicpingshort.wav"

-- ============ Limb animation ============
-- Works with R6 and R15.
local function getLegMotors(char: Model): { Motor6D }
	local motors = {}
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return motors
	end
	-- R6
	local r6hip = hrp:FindFirstChild("Right Hip")
	if r6hip and r6hip:IsA("Motor6D") then
		table.insert(motors, r6hip)
		return motors
	end
	-- R15
	local lowerTorso = char:FindFirstChild("LowerTorso")
	if lowerTorso then
		local hip = lowerTorso:FindFirstChild("RightHip")
		if hip and hip:IsA("Motor6D") then
			table.insert(motors, hip)
		end
	end
	local upperLeg = char:FindFirstChild("RightUpperLeg")
	if upperLeg then
		local knee = upperLeg:FindFirstChild("RightKnee")
		if knee and knee:IsA("Motor6D") then
			table.insert(motors, knee)
		end
	end
	return motors
end

local kicking = false

function CombatClient.playKick(charged: boolean)
	if kicking then
		return
	end
	kicking = true

	local char = player.Character
	if not char then
		kicking = false
		return
	end

	local motors = getLegMotors(char)
	local originals = {}
	for i, motor in motors do
		originals[i] = { motor = motor, c0 = motor.C0, c1 = motor.C1 }
	end

	playSound(WHOOSH, 0.6, charged and 0.7 or 1.1)

	local swingTime = charged and 0.28 or 0.16
	local returnTime = charged and 0.30 or 0.20

	-- Swing forward: rotate hip so the leg goes up-front
	for i, orig in originals do
		local isKnee = orig.motor.Name == "RightKnee"
		local swing = isKnee
			and CFrame.Angles(math.rad(charged and -70 or -40), 0, 0)
			or CFrame.Angles(math.rad(charged and -110 or -75), 0, 0)

		TweenService:Create(orig.motor, TweenInfo.new(swingTime, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			C0 = orig.c0 * swing,
			C1 = orig.c1,
		}):Play()
	end

	task.delay(swingTime, function()
		for i, orig in originals do
			if orig.motor.Parent then
				TweenService:Create(orig.motor, TweenInfo.new(returnTime, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {
					C0 = orig.c0,
					C1 = orig.c1,
				}):Play()
			end
		end
	end)

	task.delay(swingTime + returnTime + 0.05, function()
		-- hard reset to avoid drift
		for _, orig in originals do
			if orig.motor.Parent then
				orig.motor.C0 = orig.c0
				orig.motor.C1 = orig.c1
			end
		end
		kicking = false
	end)

	-- Charge glow while swinging
	if charged then
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			local light = Instance.new("PointLight")
			light.Color = Color3.fromRGB(255, 160, 60)
			light.Range = 14
			light.Brightness = 3
			light.Parent = hrp
			Debris:AddItem(light, 0.5)
		end
	end
end

-- ============ Hit VFX at target position ============
function CombatClient.hitVFX(position: Vector3, crit: boolean)
	playSound(HIT, 0.8, crit and 0.8 or 1.2)

	-- Impact burst
	local burst = Instance.new("Part")
	burst.Shape = Enum.PartType.Ball
	burst.Size = Vector3.new(1, 1, 1)
	burst.Position = position
	burst.Anchored = true
	burst.CanCollide = false
	burst.CanQuery = false
	burst.Material = Enum.Material.Neon
	burst.Color = crit and Color3.fromRGB(255, 90, 40) or Color3.fromRGB(255, 230, 120)
	burst.Transparency = 0.2
	burst.Parent = workspace
	Debris:AddItem(burst, 0.3)

	TweenService:Create(burst, TweenInfo.new(0.25), {
		Size = crit and Vector3.new(7, 7, 7) or Vector3.new(4, 4, 4),
		Transparency = 1,
	}):Play()

	-- Sparks
	local emitter = Instance.new("ParticleEmitter")
	emitter.Color = ColorSequence.new(burst.Color)
	emitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(1, 0),
	})
	emitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 1),
	})
	emitter.Lifetime = NumberRange.new(0.2, 0.5)
	emitter.Speed = NumberRange.new(15, 35)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Rate = 0
	emitter:Emit(crit and 30 or 15)
	emitter.Parent = burst
end

-- ============ Screen shake ============
local shakeAmount = 0

function CombatClient.shake(amount: number)
	shakeAmount = math.max(shakeAmount, amount)
end

RunService.RenderStepped:Connect(function(dt)
	if shakeAmount > 0.05 then
		local offset = Vector3.new(
			(math.random() - 0.5) * shakeAmount,
			(math.random() - 0.5) * shakeAmount,
			0
		)
		camera.CFrame = camera.CFrame * CFrame.new(offset)
		shakeAmount = math.max(0, shakeAmount - dt * 18)
	end
end)

-- ============ Impact while being hit ============
function CombatClient.onKicked(damage: number)
	CombatClient.shake(math.clamp(damage / 8, 2, 7))
	playSound(PING, 0.5, 1.4)
end

function CombatClient.onLanded(damage: number, crit: boolean)
	CombatClient.shake(crit and 5 or 2.5)
end

return CombatClient
