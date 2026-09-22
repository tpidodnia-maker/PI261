--!strict
-- Rarity tiers with colors and stat ranges.

export type Rarity = "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary" | "Mythic" | "Cosmic"

local RarityConfig: { [Rarity]: {
	color: Color3,
	statBase: number,
	statVariance: number,
	fusionStarsMax: number,
}} = {
	Common    = { color = Color3.fromRGB(170, 170, 170), statBase = 1.0,  statVariance = 0.1,  fusionStarsMax = 3 },
	Uncommon  = { color = Color3.fromRGB(90, 220, 90),   statBase = 1.5,  statVariance = 0.15, fusionStarsMax = 3 },
	Rare      = { color = Color3.fromRGB(80, 150, 255),  statBase = 2.5,  statVariance = 0.2,  fusionStarsMax = 4 },
	Epic      = { color = Color3.fromRGB(170, 90, 255),  statBase = 4.0,  statVariance = 0.25, fusionStarsMax = 4 },
	Legendary = { color = Color3.fromRGB(255, 200, 50),  statBase = 7.0,  statVariance = 0.3,  fusionStarsMax = 5 },
	Mythic    = { color = Color3.fromRGB(255, 80, 130),  statBase = 12.0, statVariance = 0.35, fusionStarsMax = 5 },
	Cosmic    = { color = Color3.fromRGB(255, 255, 255), statBase = 25.0, statVariance = 0.5,  fusionStarsMax = 6 },
}

local ORDER: { Rarity } = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Cosmic" }

function RarityConfig.get(rarity: Rarity)
	return RarityConfig[rarity]
end

function RarityConfig.next(rarity: Rarity): Rarity?
	local idx = table.find(ORDER, rarity)
	if idx and idx < #ORDER then
		return ORDER[idx + 1]
	end
	return nil
end

return RarityConfig
