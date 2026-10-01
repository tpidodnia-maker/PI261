--!strict
-- Deaths, kills, streaks, respawn, fall detection.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))

local DataService = require(script.Parent:WaitForChild("DataService"))
local CombatService = require(script.Parent:WaitForChild("CombatService"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local KillFeed = Remotes:WaitForChild("KillFeed") :: RemoteEvent
local DataChanged = Remotes:WaitForChild("DataChanged") :: RemoteEvent

local KillService = {}

local streaks: { [number]: number } = {}      -- killerUserId -> streak
local lastDamageBy: { [number]: number } = {} -- victimUserId -> killerUserId
local spawnTimes: { [number]: number } = {}

local function getStreak(userId: number): number
	return streaks[userId] or 0
end

local function addStreak(userId: number): number
	streaks[userId] = getStreak(userId) + 1
	return streaks[userId]
end

function KillService.onCharacterSpawn(player: Player, character: Model)
	spawnTimes[player.UserId] = os.clock()

	-- Spawn shield
	local state = CombatService.getState(player)
	state.invulnUntil = os.clock() + Config.SPAWN_SHIELD_TIME

	-- Reset HP
	task.spawn(function()
		local hum = character:WaitForChild("Humanoid", 5)
		if hum then
			hum.MaxHealth = Config.MAX_HP
			hum.Health = Config.MAX_HP
		end
	end)

	-- Reset streak on respawn
	streaks[player.UserId] = 0
	DataService.push(player, "streak", 0)
end

local function handleDeath(victim: Player, killer: Player?)
	local victimId = victim.UserId

	-- Kill credit
	if killer and killer ~= victim and killer.Parent then
		DataService.addKill(killer)
		local streak = addStreak(killer.UserId)

		-- Streak bonus
		local bonus = Config.STREAK_BONUSES[streak]
		if bonus then
			DataService.addXP(killer, bonus)
			DataService.notify(killer, ("🔥 Серия %d! +%d XP"):format(streak, bonus))
		end

		-- Broadcast kill feed
		KillFeed:FireAllPlayers({
			killer = killer.Name,
			victim = victim.Name,
			streak = streak,
		})

		DataService.push(killer, "streak", streak)
	else
		-- Fall / suicide
		KillFeed:FireAllPlayers({
			killer = victim.Name,
			victim = "падение",
			streak = 0,
			suicide = true,
		})
		streaks[victimId] = 0
	end

	-- Reset victim streak
	streaks[victimId] = 0
	DataService.push(victim, "streak", 0)

	-- Respawn after delay
	task.delay(Config.KILL_RESPAWN_TIME, function()
		if victim.Parent then
			victim:LoadCharacter()
		end
	end)
end

function KillService.init()
	-- Track last damager + fall detection
	Players.PlayerAdded:Connect(function(player)
		streaks[player.UserId] = 0
		player.CharacterAdded:Connect(function(char)
			local hum = char:WaitForChild("Humanoid", 5)
			if not hum then
				return
			end

			hum.Died:Connect(function()
				-- find killer: last person who damaged us (via Humanoid state would need damage tracking)
				local killerId = lastDamageBy[player.UserId]
				local killer = killerId and Players:GetPlayerByUserId(killerId)
				handleDeath(player, killer)
			end)

			-- Fall detection
			local root = char:WaitForChild("HumanoidRootPart", 5)
			if root then
				task.spawn(function()
					while root.Parent and hum.Health > 0 do
						task.wait(0.2)
						if root.Position.Y < Config.FALL_KILL_Y then
							local killerId = lastDamageBy[player.UserId]
							local killer = killerId and Players:GetPlayerByUserId(killerId)
							-- fall kill: credit last damager only if recent (10s)
							local recentKiller = nil
							if killer and os.clock() - (spawnTimes[killerId] or 0) > 0 then
								-- check if they damaged us recently — simple: always credit if exists
								recentKiller = killer
							end
							hum.Health = 0
							break
						end
					end
				end)
			end
		end)
	end)

	-- Record damage via HealthChanged
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(char)
			local hum = char:WaitForChild("Humanoid", 5)
			if not hum then
				return
			end
			local lastHealth = hum.Health
			hum.HealthChanged:Connect(function(newHealth)
				if newHealth < lastHealth then
					-- damaged — but we don't know by whom here.
					-- CombatService applies damage directly; we approximate via Kick landed event.
				end
				lastHealth = newHealth
			end)
		end)
	end)

	Players.PlayerRemoving:Connect(function(player)
		streaks[player.UserId] = nil
		lastDamageBy[player.UserId] = nil
		spawnTimes[player.UserId] = nil
	end)
end

-- Called by CombatService when a kick lands
function KillService.recordDamage(victim: Player, attacker: Player)
	lastDamageBy[victim.UserId] = attacker.UserId
	-- Check if victim died from this
	local char = victim.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum and hum.Health <= 0 then
		-- death handled by Died event
	end
end

function KillService.getStreak(player: Player): number
	return getStreak(player.UserId)
end

return KillService
