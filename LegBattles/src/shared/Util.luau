--!strict
-- Shared helpers.

local Util = {}

function Util.formatNumber(n: number): string
	local abs = math.abs(n)
	if abs >= 1e6 then
		return string.format("%.1fM", n / 1e6)
	elseif abs >= 1e3 then
		return string.format("%.1fK", n / 1e3)
	end
	return tostring(math.floor(n))
end

function Util.levelFromXP(xp: number, base: number, growth: number): (number, number)
	local level = 1
	local needed = base
	local remaining = xp
	while remaining >= needed do
		remaining -= needed
		level += 1
		needed = math.floor(base * growth ^ (level - 1))
	end
	return level, remaining
end

function Util.deepCopy<T>(t: T): T
	if typeof(t) ~= "table" then
		return t
	end
	local copy = {}
	for k, v in t :: any do
		copy[k] = Util.deepCopy(v)
	end
	return copy :: any
end

-- Unit horizontal direction from A to B (ignores Y)
function Util.flatDir(from: Vector3, to: Vector3): Vector3
	local d = Vector3.new(to.X - from.X, 0, to.Z - from.Z)
	if d.Magnitude < 0.001 then
		return Vector3.new(0, 0, -1)
	end
	return d.Unit
end

return Util
