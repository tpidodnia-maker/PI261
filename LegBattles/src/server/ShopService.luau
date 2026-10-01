--!strict
-- Shoe shop: buy and equip.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ShoeDatabase = require(Shared:WaitForChild("ShoeDatabase"))

local DataService = require(script.Parent:WaitForChild("DataService"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local BuyShoe = Remotes:WaitForChild("BuyShoe") :: RemoteEvent
local EquipShoe = Remotes:WaitForChild("EquipShoe") :: RemoteEvent

local ShopService = {}

local function handleBuy(player: Player, shoeId: unknown)
	if typeof(shoeId) ~= "string" then
		return
	end
	local def = ShoeDatabase.get(shoeId :: string)
	if not def then
		return
	end
	if DataService.ownsShoe(player, shoeId :: string) then
		DataService.notify(player, "Эта обувь уже куплена!", true)
		return
	end
	local data = DataService.get(player)
	if not data or data.kills < def.cost then
		DataService.notify(player, ("Нужно %d убийств (есть %d)"):format(def.cost, data and data.kills or 0), true)
		return
	end

	-- Deduct kills (kills are currency — spend them)
	data.kills -= def.cost
	DataService.push(player, "kills", data.kills)
	DataService.syncLeaderstats(player)

	DataService.grantShoe(player, shoeId :: string)
	DataService.notify(player, "Куплено: " .. def.name .. "! 👟")
end

local function handleEquip(player: Player, shoeId: unknown)
	if typeof(shoeId) ~= "string" then
		return
	end
	if not DataService.ownsShoe(player, shoeId :: string) then
		DataService.notify(player, "Сначала купи эту обувь!", true)
		return
	end
	DataService.setEquippedShoe(player, shoeId :: string)
	local def = ShoeDatabase.get(shoeId :: string)
	if def then
		DataService.notify(player, "Надето: " .. def.name)
	end
end

function ShopService.init()
	BuyShoe.OnServerEvent:Connect(handleBuy)
	EquipShoe.OnServerEvent:Connect(handleEquip)
end

return ShopService
