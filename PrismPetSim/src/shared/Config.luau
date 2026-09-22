--!strict
-- Crystalis — Global Configuration
-- All balance numbers live here. Tune the game from one file.

local Config = {
	-- Currency
	STARTING_LUMENS = 0,
	STARTING_CRYSTALS = {},

	-- Mining
	MINE_BASE_YIELD = 1,
	MINE_BASE_COOLDOWN = 0.35,
	MINE_CRIT_CHANCE = 0.05,
	MINE_CRIT_MULTIPLIER = 5,

	-- Hatching
	HATCH_BASE_COST = 100,
	HATCH_COST_GROWTH = 1.35,       -- each egg tier costs previous * growth
	ANIMATION_DURATION = 1.2,

	-- Pets
	MAX_PET_SLOTS = 4,              -- pets that follow you / give bonuses
	INVENTORY_CAP = 50,
	FUSION_ENABLED = true,
	FUSION_RESULT_BONUS = 0.5,      -- +50% stats per fusion star

	-- Crystallization (pet levelling)
	XP_CURVE_BASE = 1.25,           -- xp needed = base * level ^ curve
	XP_BASE = 10,
	MAX_PET_LEVEL = 50,

	-- Rebirth
	REBIRTH_BASE_COST = 10_000,
	REBIRTH_COST_GROWTH = 2.5,
	REBIRTH_LUMEN_BONUS = 0.25,     -- +25% lumens per rebirth
	REBIRTH_LUCK_BONUS = 0.10,      -- +10% hatch luck per rebirth

	-- Zones
	ZONES = {
		{
			id = "meadow",
			name = "Радужная Луговина",
			color = Color3.fromRGB(120, 220, 120),
			cost = 0,
			yieldMultiplier = 1,
			rarityWeights = { Common = 80, Uncommon = 18, Rare = 2 },
		},
		{
			id = "frost",
			name = "Ледяной Призма",
			color = Color3.fromRGB(120, 200, 255),
			cost = 5_000,
			yieldMultiplier = 3,
			rarityWeights = { Common = 55, Uncommon = 30, Rare = 12, Epic = 3 },
		},
		{
			id = "ember",
			name = "Обсидиановый Кратер",
			color = Color3.fromRGB(255, 140, 60),
			cost = 50_000,
			yieldMultiplier = 8,
			rarityWeights = { Uncommon = 50, Rare = 32, Epic = 14, Legendary = 4 },
		},
		{
			id = "void",
			name = "Пустота",
			color = Color3.fromRGB(160, 80, 255),
			cost = 500_000,
			yieldMultiplier = 25,
			rarityWeights = { Rare = 45, Epic = 35, Legendary = 15, Mythic = 5 },
		},
		{
			id = "prism",
			name = "Сердце Призмы",
			color = Color3.fromRGB(255, 255, 255),
			cost = 5_000_000,
			yieldMultiplier = 100,
			rarityWeights = { Epic = 40, Legendary = 35, Mythic = 20, Cosmic = 5 },
		},
	},

	-- Elements: color + icon glyph for UI
	ELEMENTS = {
		Fire  = { color = Color3.fromRGB(255, 90, 50),  glyph = "🔥" },
		Ice   = { color = Color3.fromRGB(120, 210, 255), glyph = "❄️" },
		Nature= { color = Color3.fromRGB(100, 220, 100), glyph = "🌿" },
		Light = { color = Color3.fromRGB(255, 240, 150), glyph = "✨" },
		Dark  = { color = Color3.fromRGB(140, 80, 200),  glyph = "🌑" },
	},

	-- Save
	DATASTORE_KEY = "Crystalis_v1",
	AUTOSAVE_INTERVAL = 120,
}

return Config
