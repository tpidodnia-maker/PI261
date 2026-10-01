--!strict
-- Arena v2: looks good — lighting, atmosphere, decorated map.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local ArenaService = {}

local function part(props: { [string]: any }): Part
	local p = Instance.new("Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in props do
		(p :: any)[k] = v
	end
	return p
end

local function neonStrip(size: Vector3, pos: Vector3, color: Color3, parent: Instance)
	part({
		Name = "Strip",
		Size = size,
		Position = pos,
		Color = color,
		Material = Enum.Material.Neon,
		Transparency = 0.1,
	}).Parent = parent
end

function ArenaService.build()
	if Workspace:FindFirstChild("LegBattlesArena") then
		return
	end

	-- ============ LIGHTING ============
	Lighting.ClockTime = 17.5
	Lighting.Brightness = 2.4
	Lighting.Ambient = Color3.fromRGB(70, 60, 90)
	Lighting.OutdoorAmbient = Color3.fromRGB(110, 100, 140)
	Lighting.FogEnd = 800
	Lighting.FogColor = Color3.fromRGB(90, 80, 120)
	Lighting.EnvironmentDiffuseScale = 0.6
	Lighting.GlobalShadows = true

	for _, c in Lighting:GetChildren() do
		if c:IsA("Atmosphere") or c:IsA("Sky") or c:IsA("ColorCorrectionEffect") or c:IsA("BloomEffect") then
			c:Destroy()
		end
	end

	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Density = 0.35
	atmosphere.Offset = 0.3
	atmosphere.Color = Color3.fromRGB(200, 180, 230)
	atmosphere.Decay = Color3.fromRGB(120, 90, 160)
	atmosphere.Glare = 0.2
	atmosphere.Haze = 1.5
	atmosphere.Parent = Lighting

	local bloom = Instance.new("BloomEffect")
	bloom.Intensity = 0.6
	bloom.Size = 32
	bloom.Threshold = 1.1
	bloom.Parent = Lighting

	local cc = Instance.new("ColorCorrectionEffect")
	cc.Contrast = 0.08
	cc.Saturation = 0.15
	cc.TintColor = Color3.fromRGB(255, 245, 255)
	cc.Parent = Lighting

	local sky = Instance.new("Sky")
	sky.SkyboxBk = "rbxassetid://151685497"
	sky.SkyboxDn = "rbxassetid://151685497"
	sky.SkyboxFt = "rbxassetid://151685497"
	sky.SkyboxLf = "rbxassetid://151685497"
	sky.SkyboxRt = "rbxassetid://151685497"
	sky.SkyboxUp = "rbxassetid://151685497"
	sky.StarCount = 0
	sky.Parent = Lighting

	local arena = Instance.new("Folder")
	arena.Name = "LegBattlesArena"

	-- ============ MAIN FLOOR ============
	part({
		Name = "MainPlatform",
		Size = Vector3.new(100, 4, 100),
		Position = Vector3.new(0, 0, 0),
		Color = Color3.fromRGB(45, 45, 65),
		Material = Enum.Material.Slate,
	}).Parent = arena

	-- Floor grid lines (neon)
	for i = -4, 4 do
		neonStrip(Vector3.new(100, 0.15, 0.3), Vector3.new(0, 2.08, i * 11), Color3.fromRGB(90, 70, 200), arena)
		neonStrip(Vector3.new(0.3, 0.15, 100), Vector3.new(i * 11, 2.08, 0), Color3.fromRGB(90, 70, 200), arena)
	end

	-- Edge glow frame
	neonStrip(Vector3.new(102, 0.5, 1), Vector3.new(0, 2.2, -50.5), Color3.fromRGB(255, 90, 60), arena)
	neonStrip(Vector3.new(102, 0.5, 1), Vector3.new(0, 2.2, 50.5), Color3.fromRGB(255, 90, 60), arena)
	neonStrip(Vector3.new(1, 0.5, 102), Vector3.new(-50.5, 2.2, 0), Color3.fromRGB(255, 90, 60), arena)
	neonStrip(Vector3.new(1, 0.5, 102), Vector3.new(50.5, 2.2, 0), Color3.fromRGB(255, 90, 60), arena)

	-- Center arena circle marker
	local centerDisc = part({
		Name = "CenterDisc",
		Size = Vector3.new(20, 0.3, 20),
		Position = Vector3.new(0, 2.2, 0),
		Color = Color3.fromRGB(255, 120, 50),
		Material = Enum.Material.Neon,
		Transparency = 0.55,
		Shape = Enum.PartType.Cylinder,
	})
	centerDisc.Orientation = Vector3.new(0, 0, 90)
	centerDisc.Parent = arena

	-- ============ PITS (fall = death) ============
	for _, offset in { Vector3.new(-1, 0, -1), Vector3.new(1, 0, -1), Vector3.new(-1, 0, 1), Vector3.new(1, 0, 1) } do
		part({
			Name = "Pit",
			Size = Vector3.new(30, 1, 30),
			Position = Vector3.new(offset.X * 65, -1, offset.Z * 65),
			Color = Color3.fromRGB(255, 60, 30),
			Material = Enum.Material.Neon,
			Transparency = 0.55,
		}).Parent = arena
	end

	-- ============ ELEVATED PLATFORMS ============
	local platforms = {
		{ size = Vector3.new(30, 2, 30), pos = Vector3.new(0, 12, -35), color = Color3.fromRGB(60, 60, 95) },
		{ size = Vector3.new(30, 2, 30), pos = Vector3.new(0, 12, 35), color = Color3.fromRGB(60, 60, 95) },
		{ size = Vector3.new(24, 2, 24), pos = Vector3.new(-35, 12, 0), color = Color3.fromRGB(60, 60, 95) },
		{ size = Vector3.new(24, 2, 24), pos = Vector3.new(35, 12, 0), color = Color3.fromRGB(60, 60, 95) },
		{ size = Vector3.new(20, 2, 20), pos = Vector3.new(-25, 24, -25), color = Color3.fromRGB(75, 55, 110) },
		{ size = Vector3.new(20, 2, 20), pos = Vector3.new(25, 24, 25), color = Color3.fromRGB(75, 55, 110) },
		{ size = Vector3.new(14, 2, 14), pos = Vector3.new(0, 36, 0), color = Color3.fromRGB(255, 200, 60) },
	}
	for i, pl in platforms do
		part({
			Name = "Platform" .. i,
			Size = pl.size,
			Position = pl.pos,
			Color = pl.color,
			Material = Enum.Material.Metal,
		}).Parent = arena

		-- glowing rim
		neonStrip(Vector3.new(pl.size.X + 0.5, 0.4, 0.5), Vector3.new(pl.pos.X, pl.pos.Y + 1.2, pl.pos.Z - pl.size.Z / 2), Color3.fromRGB(100, 200, 255), arena)
		neonStrip(Vector3.new(pl.size.X + 0.5, 0.4, 0.5), Vector3.new(pl.pos.X, pl.pos.Y + 1.2, pl.pos.Z + pl.size.Z / 2), Color3.fromRGB(100, 200, 255), arena)

		-- pillar
		part({
			Name = "Pillar" .. i,
			Size = Vector3.new(3, pl.pos.Y - 2, 3),
			Position = Vector3.new(pl.pos.X, (pl.pos.Y - 2) / 2, pl.pos.Z),
			Color = Color3.fromRGB(35, 35, 55),
			Material = Enum.Material.Slate,
		}).Parent = arena
	end

	-- Top trophy pedestal glow
	local topGlow = part({
		Name = "TopGlow",
		Size = Vector3.new(2, 2, 2),
		Position = Vector3.new(0, 39, 0),
		Transparency = 1,
		CanCollide = false,
	})
	local topLight = Instance.new("PointLight")
	topLight.Color = Color3.fromRGB(255, 220, 120)
	topLight.Range = 30
	topLight.Brightness = 2
	topLight.Parent = topGlow
	topGlow.Parent = arena

	-- ============ RAMP CONNECTIONS ============
	local ramps = {
		{ pos = Vector3.new(0, 7, -48), rot = math.rad(-25) },
		{ pos = Vector3.new(0, 7, 48), rot = math.rad(25) },
		{ pos = Vector3.new(-48, 7, 0), rot = math.rad(0), flip = true },
		{ pos = Vector3.new(48, 7, 0), rot = math.rad(0), flip = true },
	}
	for i, r in ramps do
		local ramp = part({
			Name = "Ramp" .. i,
			Size = r.flip and Vector3.new(24, 1.5, 14) or Vector3.new(14, 1.5, 24),
			Position = r.pos,
			Color = Color3.fromRGB(55, 55, 85),
			Material = Enum.Material.Metal,
		})
		if r.flip then
			ramp.CFrame = CFrame.new(r.pos) * CFrame.Angles(0, 0, math.rad(-25))
		else
			ramp.CFrame = CFrame.new(r.pos) * CFrame.Angles(r.rot, 0, 0)
		end
		ramp.Parent = arena
	end

	-- ============ JUMP PADS ============
	for i, pos in { Vector3.new(-18, 2.5, 0), Vector3.new(18, 2.5, 0) } do
		local pad = part({
			Name = "JumpPad" .. i,
			Size = Vector3.new(8, 1, 8),
			Position = pos,
			Color = Color3.fromRGB(60, 255, 140),
			Material = Enum.Material.Neon,
			Shape = Enum.PartType.Cylinder,
		})
		pad.Orientation = Vector3.new(0, 0, 90)
		local glow = Instance.new("PointLight")
		glow.Color = Color3.fromRGB(60, 255, 140)
		glow.Range = 16
		glow.Brightness = 2
		glow.Parent = pad
		pad.Touched:Connect(function(hit)
			local hum = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 then
				local root = hit.Parent:FindFirstChild("HumanoidRootPart")
				if root then
					root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 95, root.AssemblyLinearVelocity.Z)
				end
			end
		end)
		pad.Parent = arena
	end

	-- ============ DECOR: floating crystals ============
	for i = 1, 14 do
		local angle = (i / 14) * math.pi * 2
		local radius = 75 + math.random(-8, 8)
		local height = 15 + math.random(0, 35)
		local crystal = part({
			Name = "Crystal" .. i,
			Size = Vector3.new(math.random(2, 4), math.random(4, 9), math.random(2, 4)),
			Position = Vector3.new(math.cos(angle) * radius, height, math.sin(angle) * radius),
			Color = Color3.fromHSV((i / 14), 0.7, 1),
			Material = Enum.Material.Neon,
			Transparency = 0.25,
			CanCollide = false,
		})
		crystal.Orientation = Vector3.new(math.random(-25, 25), math.random(0, 360), math.random(-25, 25))

		-- slow spin
		task.spawn(function()
			while crystal.Parent do
				local dt = task.wait(0.05)
				crystal.CFrame = crystal.CFrame * CFrame.Angles(0, dt * 0.6, 0)
				crystal.Position += Vector3.new(0, math.sin(os.clock() * 0.8 + i) * 0.02, 0)
			end
		end)
		crystal.Parent = arena
	end

	-- ============ SPAWNS ============
	for i, pos in { Vector3.new(-40, 6, -40), Vector3.new(40, 6, -40), Vector3.new(-40, 6, 40), Vector3.new(40, 6, 40) } do
		local spawn = Instance.new("SpawnLocation")
		spawn.Name = "Spawn" .. i
		spawn.Size = Vector3.new(10, 1, 10)
		spawn.Position = pos
		spawn.Anchored = true
		spawn.Neutral = true
		spawn.Color = Color3.fromRGB(80, 160, 255)
		spawn.Material = Enum.Material.Neon
		spawn.Transparency = 0.35
		spawn.Duration = 0
		local light = Instance.new("PointLight")
		light.Color = Color3.fromRGB(80, 160, 255)
		light.Range = 18
		light.Brightness = 2
		light.Parent = spawn
		spawn.Parent = arena
	end

	-- ============ INVISIBLE WALLS ============
	local walls = {
		{ size = Vector3.new(220, 80, 2), pos = Vector3.new(0, 40, -111) },
		{ size = Vector3.new(220, 80, 2), pos = Vector3.new(0, 40, 111) },
		{ size = Vector3.new(2, 80, 220), pos = Vector3.new(-111, 40, 0) },
		{ size = Vector3.new(2, 80, 220), pos = Vector3.new(111, 40, 0) },
	}
	for i, w in walls do
		part({
			Name = "Wall" .. i,
			Size = w.size,
			Position = w.pos,
			Transparency = 1,
		}).Parent = arena
	end

	arena.Parent = Workspace
	print("[LegBattles] Arena v2 built.")
end

return ArenaService
