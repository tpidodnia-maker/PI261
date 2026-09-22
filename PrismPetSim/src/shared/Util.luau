--!strict
-- Shared utility helpers.

local Util = {}

-- Weighted random pick. weights = { key = weight, ... }
function Util.weightedPick<T>(weights: { [T]: number }): T?
	local total = 0
	for _, w in weights do
		total += w
	end
	if total <= 0 then
		return nil
	end
	local roll = math.random() * total
	local acc = 0
	for key, w in weights do
		acc += w
		if roll <= acc then
			return key
		end
	end
	-- floating point fallback: return last key
	local last: T? = nil
	for key in weights do
		last = key
	end
	return last
end

-- Format large numbers: 1234567 -> "1.23M"
function Util.formatNumber(n: number): string
	local abs = math.abs(n)
	if abs >= 1e9 then
		return string.format("%.2fB", n / 1e9)
	elseif abs >= 1e6 then
		return string.format("%.2fM", n / 1e6)
	elseif abs >= 1e3 then
		return string.format("%.1fK", n / 1e3)
	end
	return tostring(math.floor(n))
end

-- XP needed to go from `level` to `level + 1`
function Util.xpForLevel(level: number, base: number, curve: number): number
	return math.floor(base * level ^ curve)
end

-- Deep copy tables (no cycles expected in our data)
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

return Util
