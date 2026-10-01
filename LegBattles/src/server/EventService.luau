--!strict
-- Last Standing event: every 5 min, 60s survival = win.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))

local DataService = require(script.Parent:WaitForChild("DataService"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Notify = Remotes:WaitForChild("Notify") :: RemoteEvent

local EventService = {}

local active = false
local alive: { [number]: boolean } = {}

local function broadcast(message: string)
	Notify:FireAllPlayers(message, false)
end

local function startLastStanding()
	local players = Players:GetPlayers()
	if #players < Config.LAST_STANDING_MIN_PLAYERS then
		return
	end

	active = true
	alive = {}
	for _, p in players do
		alive[p.UserId] = true
	end

	broadcast("⚔️ LAST STANDING! Выживи " .. Config.LAST_STANDING_DURATION .. " секунд!")

	task.delay(Config.LAST_STANDING_DURATION, function()
		if not active then
			return
		end
		active = false

		local winners = 0
		for userId in alive do
			local p = Players:GetPlayerByUserId(userId)
			if p and p.Parent then
				DataService.addWin(p)
				DataService.notify(p, "🏆 Ты выжил в Last Standing! +1 Wins")
				winners += 1
			end
		end
		if winners == 0 then
			broadcast("Last Standing окончен — никто не выжил.")
		else
			broadcast(("Last Standing окончен! Победили: %d"):format(winners))
		end
	end)
end

-- Called by KillService on death during event
function EventService.onPlayerDied(player: Player)
	if active and alive[player.UserId] then
		alive[player.UserId] = nil
		if active then
			-- count remaining
			local remaining = 0
			for _, v in alive do
				if v then
					remaining += 1
				end
			end
			-- notify via kill feed handled elsewhere
		end
	end
end

function EventService.isActive(): boolean
	return active
end

function EventService.init()
	task.spawn(function()
		while true do
			task.wait(Config.LAST_STANDING_INTERVAL)
			startLastStanding()
		end
	end)
end

return EventService
