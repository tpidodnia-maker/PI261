--!strict
-- LEG BATTLES — Global Configuration

local Config = {
	-- Combat
	KICK_DAMAGE = 25,
	KICK_RANGE = 8,
	KICK_COOLDOWN = 0.8,
	CHARGE_TIME = 0.6,
	CHARGE_COOLDOWN = 1.5,
	CHARGE_KNOCKBACK_MULT = 2.0,
	JUMP_KICK_BONUS = 0.5,
	BACKSTAB_MULT = 1.5,
	BASE_KNOCKBACK = 40,

	-- Player
	MAX_HP = 100,
	REGEN_AMOUNT = 5,
	REGEN_DELAY = 3,
	SPAWN_SHIELD_TIME = 2,
	KILL_RESPAWN_TIME = 3,
	FALL_KILL_Y = -50,

	-- Progression
	STARTING_KILLS = 0,
	STREAK_BONUSES = { [3] = 5, [5] = 10, [10] = 25 },
	XP_PER_KILL = 10,
	XP_PER_KICK = 1,
	LEVEL_BASE_XP = 100,
	LEVEL_XP_GROWTH = 1.3,

	-- Modes
	LAST_STANDING_INTERVAL = 300,   -- every 5 min
	LAST_STANDING_DURATION = 60,
	LAST_STANDING_MIN_PLAYERS = 2,

	-- Spawn protection after fall
	FALL_DAMAGE = 0,

	-- Remotes (created at runtime)
	REMOTES = {
		"Kick", "Ability", "Block", "BuyShoe", "EquipShoe",
		"GetData", "DataChanged", "KillFeed", "Notify",
		"AbilityReady", "ChargeKick",
	},

	-- DataStore
	DATASTORE_KEY = "LegBattles_v1",
	AUTOSAVE_INTERVAL = 120,
}

export type ZoneConfig = typeof(Config)

return Config
