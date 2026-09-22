--!strict
-- Zone unlocking.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))

local DataService = require(script.Parent:WaitForChild("DataService"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local UnlockZone = Remotes:WaitForChild("UnlockZone") :: RemoteEvent

local ZoneService = {}

local function handleUnlock(player: Player, zoneId: unknown)
	if typeof(zoneId) ~= "string" then
		return
	end
	local data = DataService.get(player)
	if not data then
		return
	end
	if table.find(data.unlockedZones, zoneId :: string) then
		return
	end

	local zone = nil
	for _, z in Config.ZONES do
		if z.id == zoneId then
			zone = z
			break
		end
	end
	if not zone then
		return
	end

	if not DataService.spendLumens(player, zone.cost) then
		DataService.notify(player, ("Нужно %d люменов"):format(zone.cost), true)
		return
	end

	table.insert(data.unlockedZones, zoneId :: string)
	DataService.push(player, "unlockedZones", data.unlockedZones)
	DataService.notify(player, "Открыта зона: " .. zone.name)
end

function ZoneService.init()
	UnlockZone.OnServerEvent:Connect(handleUnlock)
end

return ZoneService
