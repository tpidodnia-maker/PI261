--!strict
-- Procedural pet model builder.
-- Constructs a chibi-style pet from Parts based on the recipe in PetDatabase.
-- No mesh imports — everything is built at runtime.

local PetDatabase = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("PetDatabase"))

export type Recipe = PetDatabase.PetDef["recipe"]

local PetModelBuilder = {}

local function makePart(props: { [string]: any }): Part
	local p = Instance.new("Part")
	p.Anchored = false
	p.CanCollide = false
	p.CastShadow = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in props do
		(p :: any)[k] = v
	end
	return p
end

function PetModelBuilder.build(petId: string): Model?
	local def = PetDatabase.get(petId)
	if not def then
		return nil
	end
	local r = def.recipe

	local model = Instance.new("Model")
	model.Name = petId

	-- Body
	local bodyShape: Enum.PartType
	if r.bodyShape == "Ball" then
		bodyShape = Enum.PartType.Ball
	elseif r.bodyShape == "Block" then
		bodyShape = Enum.PartType.Block
	elseif r.bodyShape == "Wedge" then
		bodyShape = Enum.PartType.Wedge
	else -- Cylinder
		bodyShape = Enum.PartType.Cylinder
	end

	local body = makePart({
		Name = "Body",
		Size = r.bodySize,
		Color = r.bodyColor,
		Material = Enum.Material.SmoothPlastic,
		Shape = bodyShape,
	})
	if r.bodyShape == "Cylinder" then
		body.Orientation = Vector3.new(0, 0, 90)
	end
	body.Parent = model

	-- Head
	local head = makePart({
		Name = "Head",
		Size = r.headSize,
		Color = r.headColor,
		Material = Enum.Material.SmoothPlastic,
		Shape = Enum.PartType.Ball,
	})
	head.CFrame = CFrame.new(0, r.bodySize.Y * 0.5 + r.headSize.Y * 0.35, r.bodySize.Z * 0.2)
	head.Parent = model
	model.PrimaryPart = head

	-- Eyes
	local eyeOffsetZ = r.headSize.Z * 0.45
	local eyeSpacing = r.headSize.X * 0.28
	local eyeSize = r.eyeStyle == "Glow" and Vector3.new(0.25, 0.25, 0.15)
		or r.eyeStyle == "Slit" and Vector3.new(0.12, 0.3, 0.15)
		or Vector3.new(0.2, 0.2, 0.15)

	for _, side in { -1, 1 } do
		local eye = makePart({
			Name = "Eye",
			Size = eyeSize,
			Color = r.eyeColor,
			Material = r.eyeStyle == "Glow" and Enum.Material.Neon or Enum.Material.SmoothPlastic,
			Shape = Enum.PartType.Ball,
		})
		eye.CFrame = head.CFrame * CFrame.new(eyeSpacing * side, r.headSize.Y * 0.1, eyeOffsetZ)
		eye.Parent = model
	end

	-- Accessory
	if r.accessory and r.accessory ~= "None" then
		if r.accessory == "Horns" then
			for _, side in { -1, 1 } do
				local horn = makePart({
					Name = "Horn",
					Size = Vector3.new(0.2, 0.5, 0.2),
					Color = r.bodyColor:Lerp(Color3.new(1, 1, 1), 0.4),
					Material = Enum.Material.SmoothPlastic,
					Shape = Enum.PartType.Wedge,
				})
				horn.CFrame = head.CFrame * CFrame.new(r.headSize.X * 0.3 * side, r.headSize.Y * 0.5, 0)
					* CFrame.Angles(0, 0, math.rad(-20 * side))
				horn.Parent = model
			end
		elseif r.accessory == "Crown" then
			local crown = makePart({
				Name = "Crown",
				Size = Vector3.new(r.headSize.X * 0.8, 0.25, r.headSize.Z * 0.8),
				Color = Color3.fromRGB(255, 215, 0),
				Material = Enum.Material.Neon,
				Shape = Enum.PartType.Cylinder,
			})
			crown.CFrame = head.CFrame * CFrame.new(0, r.headSize.Y * 0.55, 0)
				* CFrame.Angles(0, 0, math.rad(90))
			crown.Parent = model
		elseif r.accessory == "Crystal" then
			local cr = makePart({
				Name = "Crystal",
				Size = Vector3.new(0.4, 0.7, 0.4),
				Color = r.eyeColor,
				Material = Enum.Material.Neon,
				Shape = Enum.PartType.Block,
			})
			cr.CFrame = head.CFrame * CFrame.new(0, r.headSize.Y * 0.6, -r.headSize.Z * 0.1)
				* CFrame.Angles(math.rad(45), math.rad(45), 0)
			cr.Parent = model
		elseif r.accessory == "Wings" then
			for _, side in { -1, 1 } do
				local wing = makePart({
					Name = "Wing",
					Size = Vector3.new(0.15, r.bodySize.Y * 0.7, r.bodySize.Z * 0.6),
					Color = r.bodyColor:Lerp(Color3.new(1, 1, 1), 0.5),
					Material = Enum.Material.Neon,
					Shape = Enum.PartType.Wedge,
				})
				wing.CFrame = CFrame.new(r.bodySize.X * 0.55 * side, r.bodySize.Y * 0.2, -r.bodySize.Z * 0.1)
					* CFrame.Angles(0, math.rad(30 * side), 0)
				wing.Parent = model
			end
		end
		-- apply WeldConstraint from accessory to head
		for _, desc in model:GetDescendants() do
			if desc.Name == "Horn" or desc.Name == "Crown" or desc.Name == "Crystal" then
				local weld = Instance.new("WeldConstraint")
				weld.Part0 = head
				weld.Part1 = desc
				weld.Parent = desc
			elseif desc.Name == "Wing" then
				local weld = Instance.new("WeldConstraint")
				weld.Part0 = body
				weld.Part1 = desc
				weld.Parent = desc
			end
		end
	end

	-- Weld head to body
	local headWeld = Instance.new("WeldConstraint")
	headWeld.Part0 = body
	headWeld.Part1 = head
	headWeld.Parent = head

	-- Weld eyes to head
	for _, desc in model:GetDescendants() do
		if desc.Name == "Eye" then
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = head
			weld.Part1 = desc
			weld.Parent = desc
		end
	end

	-- Aura particles
	if r.aura then
		local colors = {
			Fire = Color3.fromRGB(255, 120, 40),
			Ice = Color3.fromRGB(150, 220, 255),
			Nature = Color3.fromRGB(100, 230, 100),
			Light = Color3.fromRGB(255, 255, 180),
			Dark = Color3.fromRGB(160, 80, 255),
		}
		local emitter = Instance.new("ParticleEmitter")
		emitter.Color = ColorSequence.new(colors[r.aura :: string] or Color3.new(1, 1, 1))
		emitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(1, 0),
		})
		emitter.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(1, 1),
		})
		emitter.Lifetime = NumberRange.new(0.5, 1.2)
		emitter.Rate = 8
		emitter.Speed = NumberRange.new(1, 3)
		emitter.SpreadAngle = Vector2.new(360, 360)
		emitter.Parent = body
	end

	-- Bobbing animation attachment
	local attachment = Instance.new("Attachment")
	attachment.Name = "BobAttachment"
	attachment.Parent = body

	return model
end

-- Spawn a pet near a character, welded as a follower
function PetModelBuilder.spawnFollower(petId: string, character: Model, offset: Vector3): Model?
	local model = PetModelBuilder.build(petId)
	if not model then
		return nil
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		model:Destroy()
		return nil
	end

	model:PivotTo(CFrame.new(root.Position + offset))
	model.Parent = workspace

	-- Billboard for name
	local head = model.PrimaryPart
	if head then
		local bb = Instance.new("BillboardGui")
		bb.Size = UDim2.new(0, 120, 0, 30)
		bb.StudsOffset = Vector3.new(0, 2, 0)
		bb.AlwaysOnTop = false
		bb.Parent = head
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.TextScaled = true
		label.Font = Enum.Font.GothamBold
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.TextStrokeTransparency = 0.5
		label.Text = (PetDatabase.get(petId) :: any).name
		label.Parent = bb
	end

	return model
end

return PetModelBuilder
