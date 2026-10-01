--!strict
-- Builds the arena procedurally. No manual building needed.

local Workspace = game:GetService("Workspace")

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

function ArenaService.build()
	if Workspace:FindFirstChild("LegBattlesArena") then
		return
	end

	local arena = Instance.new("Folder")
	arena.Name = "LegBattlesArena"

	-- Kill floor (visual + detection)
	part({
		Name = "KillFloor",
		Size = Vector3.new(400, 2, 400),
		Position = Vector3.new(0, -60, 0),
		Color = Color3.fromRGB(20, 10, 30),
		Material = Enum.Material.Neon,
		Transparency = 0.5,
		CanTouch = true,
	}).Parent = arena

	-- Main platform
	part({
		Name = "MainPlatform",
		Size = Vector3.new(100, 4, 100),
		Position = Vector3.new(0, 0, 0),
		Color = Color3.fromRGB(60, 60, 80),
		Material = Enum.Material.Slate,
	}).Parent = arena

	-- Center hole (opens periodically — visual marker)
	part({
		Name = "CenterMarker",
		Size = Vector3.new(16, 4.1, 16),
		Position = Vector3.new(0, 0.05, 0),
		Color = Color3.fromRGB(255, 80, 80),
		Material = Enum.Material.Neon,
		Transparency = 0.6,
	}).Parent = arena

	-- 4 corner pits (fall = death)
	local corners = {
		Vector3.new(-50, 0, -50), Vector3.new(50, 0, -50),
		Vector3.new(-50, 0, 50), Vector3.new(50, 0, 50),
	}
	for i, _ in corners do
		-- Remove corners: build L-shaped walls instead
	end

	-- Corner cutouts: build 4 pit markers at corners (outside main platform)
	for _, offset in { Vector3.new(-1, 0, -1), Vector3.new(1, 0, -1), Vector3.new(-1, 0, 1), Vector3.new(1, 0, 1) } do
		part({
			Name = "Pit",
			Size = Vector3.new(24, 1, 24),
			Position = Vector3.new(offset.X * 62, -1, offset.Z * 62),
			Color = Color3.fromRGB(255, 50, 50),
			Material = Enum.Material.Neon,
			Transparency = 0.7,
		}).Parent = arena
	end

	-- Elevated platforms (3 levels)
	local platforms = {
		{ size = Vector3.new(30, 2, 30), pos = Vector3.new(0, 12, -35) },
		{ size = Vector3.new(30, 2, 30), pos = Vector3.new(0, 12, 35) },
		{ size = Vector3.new(24, 2, 24), pos = Vector3.new(-35, 12, 0) },
		{ size = Vector3.new(24, 2, 24), pos = Vector3.new(35, 12, 0) },
		-- second level
		{ size = Vector3.new(20, 2, 20), pos = Vector3.new(-25, 24, -25) },
		{ size = Vector3.new(20, 2, 20), pos = Vector3.new(25, 24, 25) },
		-- top
		{ size = Vector3.new(14, 2, 14), pos = Vector3.new(0, 36, 0) },
	}
	for i, pl in platforms do
		part({
			Name = "Platform" .. i,
			Size = pl.size,
			Position = pl.pos,
			Color = Color3.fromRGB(80, 80, 110),
			Material = Enum.Material.Metal,
		}).Parent = arena

		-- Support pillars
		part({
			Name = "Pillar" .. i,
			Size = Vector3.new(3, pl.pos.Y - 2, 3),
			Position = Vector3.new(pl.pos.X, (pl.pos.Y - 2) / 2, pl.pos.Z),
			Color = Color3.fromRGB(50, 50, 70),
			Material = Enum.Material.Slate,
		}).Parent = arena
	end

	-- Jump pads (2)
	for i, pos in { Vector3.new(-18, 2.5, 0), Vector3.new(18, 2.5, 0) } do
		local pad = part({
			Name = "JumpPad" .. i,
			Size = Vector3.new(8, 1, 8),
			Position = pos,
			Color = Color3.fromRGB(80, 255, 120),
			Material = Enum.Material.Neon,
		})
		local att = Instance.new("Attachment")
		att.Parent = pad
		local pv = Instance.new("VectorForce")
		pv.Attachment0 = att
		pv.Force = Vector3.new(0, 2200, 0)
		pv.RelativeTo = Enum.ActuatorRelativeTo.World
		pv.ApplyAtCenterOfMass = true
		pv.Parent = pad
		pad.Parent = arena

		-- only push players: use Touched with velocity check
		pad.Touched:Connect(function(hit)
			local hum = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 then
				local root = hit.Parent:FindFirstChild("HumanoidRootPart")
				if root then
					root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 90, root.AssemblyLinearVelocity.Z)
				end
			end
		end)
	end

	-- Spawn locations
	for i, pos in { Vector3.new(-40, 6, -40), Vector3.new(40, 6, -40), Vector3.new(-40, 6, 40), Vector3.new(40, 6, 40) } do
		local spawn = Instance.new("SpawnLocation")
		spawn.Name = "Spawn" .. i
		spawn.Size = Vector3.new(8, 1, 8)
		spawn.Position = pos
		spawn.Anchored = true
		spawn.Neutral = true
		spawn.Color = Color3.fromRGB(100, 150, 255)
		spawn.Material = Enum.Material.Neon
		spawn.Duration = 0
		spawn.Parent = arena
	end

	-- Walls (invisible boundaries to keep players in)
	local wallProps = {
		{ size = Vector3.new(200, 60, 2), pos = Vector3.new(0, 30, -101) },
		{ size = Vector3.new(200, 60, 2), pos = Vector3.new(0, 30, 101) },
		{ size = Vector3.new(2, 60, 200), pos = Vector3.new(-101, 30, 0) },
		{ size = Vector3.new(2, 60, 200), pos = Vector3.new(101, 30, 0) },
	}
	for i, w in wallProps do
		part({
			Name = "Wall" .. i,
			Size = w.size,
			Position = w.pos,
			Transparency = 1,
			CanCollide = true,
		}).Parent = arena
	end

	arena.Parent = Workspace
	print("[LegBattles] Arena built.")
end

return ArenaService
