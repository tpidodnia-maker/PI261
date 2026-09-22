--!strict
-- Builds all HUD elements programmatically. No .rbxmx required.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local PetDatabase = require(Shared:WaitForChild("PetDatabase"))
local RarityConfig = require(Shared:WaitForChild("RarityConfig"))
local Util = require(Shared:WaitForChild("Util"))

local UIBuilder = {}

type HUD = {
	root: ScreenGui,
	lumensLabel: TextLabel,
	crystalsLabel: TextLabel,
	rebirthLabel: TextLabel,
	hatchCostLabel: TextLabel,
	hatchButton: TextButton,
	inventoryButton: TextButton,
	zonesButton: TextButton,
	rebirthButton: TextButton,
	invFrame: Frame,
	invGrid: ScrollingFrame,
	zoneFrame: Frame,
	zoneList: ScrollingFrame,
	toastLabel: TextLabel,
	hatchAnimFrame: Frame,
	hatchResultLabel: TextLabel,
	minePopup: TextLabel,
	fuseSelection: { string },
}

local COLORS = {
	bg = Color3.fromRGB(25, 25, 40),
	panel = Color3.fromRGB(35, 35, 55),
	accent = Color3.fromRGB(120, 90, 255),
	accentHover = Color3.fromRGB(150, 120, 255),
	text = Color3.fromRGB(240, 240, 255),
	dim = Color3.fromRGB(150, 150, 170),
	success = Color3.fromRGB(80, 220, 120),
	error = Color3.fromRGB(255, 80, 80),
}

local function mk(className: string, props: { [string]: any }, parent: Instance?): Instance
	local obj = Instance.new(className)
	for k, v in props do
		(obj :: any)[k] = v
	end
	if parent then
		obj.Parent = parent
	end
	return obj
end

-- ============ buildHUD ============

function UIBuilder.buildHUD(): HUD
	local gui = mk("ScreenGui", {
		Name = "CrystalisHUD",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, player:WaitForChild("PlayerGui")) :: ScreenGui

	-- Top bar
	local topBar = mk("Frame", {
		Name = "TopBar",
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundColor3 = COLORS.bg,
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
	}, gui) :: Frame

	local lumensLabel = mk("TextLabel", {
		Name = "Lumens",
		Size = UDim2.new(0, 200, 1, 0),
		Position = UDim2.new(0, 15, 0, 0),
		BackgroundTransparency = 1,
		TextColor3 = COLORS.text,
		Font = Enum.Font.GothamBold,
		TextSize = 22,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "💎 0",
	}, topBar) :: TextLabel

	local crystalsLabel = mk("TextLabel", {
		Name = "Crystals",
		Size = UDim2.new(0, 180, 1, 0),
		Position = UDim2.new(0, 230, 0, 0),
		BackgroundTransparency = 1,
		TextColor3 = Color3.fromRGB(120, 200, 255),
		Font = Enum.Font.GothamBold,
		TextSize = 22,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "🔷 0",
	}, topBar) :: TextLabel

	local rebirthLabel = mk("TextLabel", {
		Name = "Rebirths",
		Size = UDim2.new(0, 80, 1, 0),
		Position = UDim2.new(0, 430, 0, 0),
		BackgroundTransparency = 1,
		TextColor3 = COLORS.accent,
		Font = Enum.Font.GothamBold,
		TextSize = 22,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "↻ 0",
	}, topBar) :: TextLabel

	-- Inventory button
	local inventoryButton = mk("TextButton", {
		Name = "InvBtn",
		Size = UDim2.new(0, 110, 0, 36),
		Position = UDim2.new(1, -360, 0, 7),
		BackgroundColor3 = COLORS.accent,
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = COLORS.text,
		Text = "🐾 Питомцы",
		AutoButtonColor = true,
		BorderSizePixel = 0,
	}, topBar) :: TextButton

	local zonesButton = mk("TextButton", {
		Name = "ZoneBtn",
		Size = UDim2.new(0, 110, 0, 36),
		Position = UDim2.new(1, -240, 0, 7),
		BackgroundColor3 = COLORS.accent,
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = COLORS.text,
		Text = "🗺 Зоны",
		AutoButtonColor = true,
		BorderSizePixel = 0,
	}, topBar) :: TextButton

	local rebirthButton = mk("TextButton", {
		Name = "RebirthBtn",
		Size = UDim2.new(0, 110, 0, 36),
		Position = UDim2.new(1, -120, 0, 7),
		BackgroundColor3 = Color3.fromRGB(200, 100, 255),
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = COLORS.text,
		Text = "↻ Ребёрс",
		AutoButtonColor = true,
		BorderSizePixel = 0,
	}, topBar) :: TextButton

	-- Bottom hatch bar
	local bottomBar = mk("Frame", {
		Name = "BottomBar",
		Size = UDim2.new(0, 320, 0, 90),
		Position = UDim2.new(0.5, -160, 1, -110),
		BackgroundColor3 = COLORS.panel,
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
	}, gui) :: Frame

	local hatchButton = mk("TextButton", {
		Name = "HatchBtn",
		Size = UDim2.new(1, -20, 0, 50),
		Position = UDim2.new(0, 10, 0, 10),
		BackgroundColor3 = COLORS.accent,
		Font = Enum.Font.GothamBold,
		TextSize = 22,
		TextColor3 = COLORS.text,
		Text = "🥚 ВЫЛУПИТЬ  [H]",
		AutoButtonColor = true,
		BorderSizePixel = 0,
	}, bottomBar) :: TextButton

	local hatchCostLabel = mk("TextLabel", {
		Name = "HatchCost",
		Size = UDim2.new(1, 0, 0, 22),
		Position = UDim2.new(0, 0, 0, 62),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = COLORS.dim,
		Text = "💎 100",
	}, bottomBar) :: TextLabel

	-- Toast
	local toastLabel = mk("TextLabel", {
		Name = "Toast",
		Size = UDim2.new(0, 400, 0, 36),
		Position = UDim2.new(0.5, -200, 0, 60),
		BackgroundColor3 = COLORS.panel,
		BackgroundTransparency = 0.2,
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = COLORS.text,
		Text = "",
		TextTransparency = 1,
		BorderSizePixel = 0,
	}, gui) :: TextLabel

	-- Mine popup
	local minePopup = mk("TextLabel", {
		Name = "MinePopup",
		Size = UDim2.new(0, 150, 0, 30),
		Position = UDim2.new(0.5, -75, 0.5, -60),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 24,
		TextColor3 = COLORS.success,
		TextStrokeTransparency = 0.5,
		Text = "",
		TextTransparency = 1,
	}, gui) :: TextLabel

	-- Hatch animation overlay
	local hatchAnimFrame = mk("Frame", {
		Name = "HatchAnim",
		Size = UDim2.new(0, 300, 0, 300),
		Position = UDim2.new(0.5, -150, 0.5, -150),
		BackgroundColor3 = COLORS.panel,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
	}, gui) :: Frame

	mk("UICorner", { CornerRadius = UDim.new(0, 16) }, hatchAnimFrame)

	local hatchResultLabel = mk("TextLabel", {
		Name = "Result",
		Size = UDim2.new(1, -20, 0, 60),
		Position = UDim2.new(0, 10, 0.5, -30),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 24,
		TextColor3 = COLORS.text,
		TextWrapped = true,
		Text = "",
	}, hatchAnimFrame) :: TextLabel

	-- Inventory panel
	local invFrame = mk("Frame", {
		Name = "Inventory",
		Size = UDim2.new(0, 520, 0, 400),
		Position = UDim2.new(0.5, -260, 0.5, -200),
		BackgroundColor3 = COLORS.panel,
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		Visible = false,
	}, gui) :: Frame

	mk("UICorner", { CornerRadius = UDim.new(0, 12) }, invFrame)
	mk("UIPadding", {
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
	}, invFrame)

	mk("TextLabel", {
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		TextColor3 = COLORS.text,
		Text = "🐾 Питомцы",
		TextXAlignment = Enum.TextXAlignment.Left,
	}, invFrame)

	local invGrid = mk("ScrollingFrame", {
		Name = "Grid",
		Size = UDim2.new(1, 0, 1, -40),
		Position = UDim2.new(0, 0, 0, 36),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = COLORS.accent,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
	}, invFrame) :: ScrollingFrame

	local gridLayout = mk("UIGridLayout", {
		CellSize = UDim2.new(0, 150, 0, 160),
		CellPadding = UDim2.new(0, 8, 0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, invGrid)

	-- Zone panel
	local zoneFrame = mk("Frame", {
		Name = "Zones",
		Size = UDim2.new(0, 400, 0, 350),
		Position = UDim2.new(0.5, -200, 0.5, -175),
		BackgroundColor3 = COLORS.panel,
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		Visible = false,
	}, gui) :: Frame

	mk("UICorner", { CornerRadius = UDim.new(0, 12) }, zoneFrame)
	mk("UIPadding", {
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
	}, zoneFrame)

	mk("TextLabel", {
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		TextColor3 = COLORS.text,
		Text = "🗺 Зоны",
		TextXAlignment = Enum.TextXAlignment.Left,
	}, zoneFrame)

	local zoneList = mk("ScrollingFrame", {
		Name = "List",
		Size = UDim2.new(1, 0, 1, -40),
		Position = UDim2.new(0, 0, 0, 36),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 6,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
	}, zoneFrame) :: ScrollingFrame

	mk("UIListLayout", {
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, zoneList)

	return {
		root = gui,
		lumensLabel = lumensLabel,
		crystalsLabel = crystalsLabel,
		rebirthLabel = rebirthLabel,
		hatchCostLabel = hatchCostLabel,
		hatchButton = hatchButton,
		inventoryButton = inventoryButton,
		zonesButton = zonesButton,
		rebirthButton = rebirthButton,
		invFrame = invFrame,
		invGrid = invGrid,
		zoneFrame = zoneFrame,
		zoneList = zoneList,
		toastLabel = toastLabel,
		hatchAnimFrame = hatchAnimFrame,
		hatchResultLabel = hatchResultLabel,
		minePopup = minePopup,
		fuseSelection = {},
	}
end

-- ============ getHatchCost (client mirror) ============
function UIBuilder.getHatchCost(data: any): number
	local count = data.pets and #data.pets or 0
	local cost = Config.HATCH_BASE_COST * Config.HATCH_COST_GROWTH ^ count
	if data.rebirths then
		cost *= 0.95 ^ data.rebirths
	end
	return math.floor(cost)
end

-- ============ updateZoneButtons ============
function UIBuilder.updateZoneButtons(hud: HUD, data: any, onUnlock: (string) -> ())
	for _, child in hud.zoneList:GetChildren() do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	for order, zone in Config.ZONES do
		local unlocked = table.find(data.unlockedZones, zone.id) ~= nil

		local row = mk("Frame", {
			Size = UDim2.new(1, -10, 0, 50),
			BackgroundColor3 = zone.color,
			BackgroundTransparency = unlocked and 0.7 or 0.85,
			BorderSizePixel = 0,
			LayoutOrder = order,
		}, hud.zoneList) :: Frame

		mk("UICorner", { CornerRadius = UDim.new(0, 8) }, row)

		mk("TextLabel", {
			Size = UDim2.new(0.6, 0, 1, 0),
			Position = UDim2.new(0, 10, 0, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 16,
			TextColor3 = COLORS.text,
			Text = zone.name,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, row)

		if unlocked then
			mk("TextLabel", {
				Size = UDim2.new(0, 80, 1, 0),
				Position = UDim2.new(1, -90, 0, 0),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				TextSize = 16,
				TextColor3 = COLORS.success,
				Text = "✓",
			}, row)
		else
			local btn = mk("TextButton", {
				Size = UDim2.new(0, 110, 1, -10),
				Position = UDim2.new(1, -120, 0, 5),
				BackgroundColor3 = COLORS.accent,
				Font = Enum.Font.GothamBold,
				TextSize = 13,
				TextColor3 = COLORS.text,
				Text = "💎 " .. Util.formatNumber(zone.cost),
				AutoButtonColor = true,
				BorderSizePixel = 0,
			}, row) :: TextButton

			mk("UICorner", { CornerRadius = UDim.new(0, 6) }, btn)

			btn.MouseButton1Click:Connect(function()
				onUnlock(zone.id)
			end)
		end
	end
end

-- ============ updatePetGrid ============
function UIBuilder.updatePetGrid(hud: HUD, data: any, callbacks: {
	onEquip: (string) -> (),
	onFuse: (string, string) -> (),
	onLevel: (string) -> (),
})
	for _, child in hud.invGrid:GetChildren() do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	hud.fuseSelection = hud.fuseSelection or {}

	for order, pet in data.pets do
		local def = PetDatabase.get(pet.petId)
		if not def then
			continue
		end
		local rarity = RarityConfig.get(def.rarity :: any)

		local card = mk("Frame", {
			Size = UDim2.new(0, 150, 0, 160),
			BackgroundColor3 = COLORS.bg,
			BackgroundTransparency = 0.2,
			BorderSizePixel = 0,
			LayoutOrder = order,
		}, hud.invGrid) :: Frame

		mk("UICorner", { CornerRadius = UDim.new(0, 10) }, card)

		-- Rarity stripe
		mk("Frame", {
			Size = UDim2.new(1, 0, 0, 4),
			BackgroundColor3 = rarity.color,
			BorderSizePixel = 0,
		}, card)

		-- Stars
		local stars = string.rep("★", pet.fusionStars) .. string.rep("☆", rarity.fusionStarsMax - pet.fusionStars)

		mk("TextLabel", {
			Size = UDim2.new(1, -8, 0, 18),
			Position = UDim2.new(0, 4, 0, 8),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			TextColor3 = rarity.color,
			Text = stars,
		}, card)

		mk("TextLabel", {
			Size = UDim2.new(1, -8, 0, 20),
			Position = UDim2.new(0, 4, 0, 28),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 16,
			TextColor3 = COLORS.text,
			Text = def.name,
		}, card)

		mk("TextLabel", {
			Size = UDim2.new(1, -8, 0, 16),
			Position = UDim2.new(0, 4, 0, 48),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextColor3 = COLORS.dim,
			Text = string.format("Ур. %d  •  %s %s", pet.level, Config.ELEMENTS[def.element].glyph, def.element),
		}, card)

		-- Equipped badge
		if pet.equipped then
			mk("TextLabel", {
				Size = UDim2.new(0, 60, 0, 18),
				Position = UDim2.new(1, -64, 0, 6),
				BackgroundColor3 = COLORS.success,
				BackgroundTransparency = 0.3,
				Font = Enum.Font.GothamBold,
				TextSize = 11,
				TextColor3 = COLORS.text,
				Text = "НА СОБЕ",
				BorderSizePixel = 0,
			}, card)
		end

		-- Buttons row
		local equipBtn = mk("TextButton", {
			Size = UDim2.new(0.5, -6, 0, 26),
			Position = UDim2.new(0, 4, 1, -30),
			BackgroundColor3 = pet.equipped and Color3.fromRGB(200, 80, 80) or COLORS.accent,
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			TextColor3 = COLORS.text,
			Text = pet.equipped and "Снять" or "Надеть",
			AutoButtonColor = true,
			BorderSizePixel = 0,
		}, card) :: TextButton

		mk("UICorner", { CornerRadius = UDim.new(0, 6) }, equipBtn)
		equipBtn.MouseButton1Click:Connect(function()
			callbacks.onEquip(pet.uid)
		end)

		local fuseBtn = mk("TextButton", {
			Size = UDim2.new(0.5, -6, 0, 26),
			Position = UDim2.new(0.5, 2, 1, -30),
			BackgroundColor3 = COLORS.accentHover,
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			TextColor3 = COLORS.text,
			Text = "Слить",
			AutoButtonColor = true,
			BorderSizePixel = 0,
		}, card) :: TextButton

		mk("UICorner", { CornerRadius = UDim.new(0, 6) }, fuseBtn)

		fuseBtn.MouseButton1Click:Connect(function()
			local sel = hud.fuseSelection
			if #sel == 0 then
				table.insert(sel, pet.uid)
				fuseBtn.Text = "Выбран"
				fuseBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
			elseif #sel == 1 and sel[1] ~= pet.uid then
				table.insert(sel, pet.uid)
				callbacks.onFuse(sel[1], sel[2])
				hud.fuseSelection = {}
			else
				hud.fuseSelection = { pet.uid }
			end
		end)

		-- Level button
		local levelBtn = mk("TextButton", {
			Size = UDim2.new(1, -8, 0, 22),
			Position = UDim2.new(0, 4, 1, -60),
			BackgroundColor3 = Color3.fromRGB(60, 60, 90),
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextColor3 = Color3.fromRGB(120, 200, 255),
			Text = "Улучшить (🔷 " .. Util.formatNumber(math.floor(Util.xpForLevel(pet.level, Config.XP_BASE, Config.XP_CURVE_BASE) * 2)) .. ")",
			AutoButtonColor = true,
			BorderSizePixel = 0,
		}, card) :: TextButton

		mk("UICorner", { CornerRadius = UDim.new(0, 6) }, levelBtn)
		levelBtn.MouseButton1Click:Connect(function()
			callbacks.onLevel(pet.uid)
		end)
	end
end

-- ============ Toast ============
local toastTween = nil
function UIBuilder.showToast(hud: HUD, message: string, isError: boolean)
	local label = hud.toastLabel
	label.Text = message
	label.TextColor3 = isError and COLORS.error or COLORS.success
	label.TextTransparency = 0

	if toastTween then
		toastTween:Cancel()
	end
	toastTween = TweenService:Create(label, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 1.5), {
		TextTransparency = 1,
		BackgroundTransparency = 1,
	})
	toastTween:Play()
end

-- ============ Mine popup ============
function UIBuilder.showMinePopup(hud: HUD, info: any)
	local label = hud.minePopup
	local text = "+" .. Util.formatNumber(info.amount) .. " 💎"
	if info.crystals > 0 then
		text ..= "  +" .. info.crystals .. " 🔷"
	end
	if info.crit then
		text = "КРИТ! " .. text
		label.TextColor3 = Color3.fromRGB(255, 200, 50)
	else
		label.TextColor3 = COLORS.success
	end
	label.Text = text
	label.TextTransparency = 0
	label.Position = UDim2.new(0.5, -75, 0.5, -60)

	TweenService:Create(label, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, -75, 0.5, -120),
		TextTransparency = 1,
	}):Play()
end

-- ============ Hatch animation ============
function UIBuilder.playHatchAnimation(hud: HUD, result: any)
	local def = PetDatabase.get(result.petId)
	if not def then
		return
	end
	local rarity = RarityConfig.get(result.rarity :: any)

	local frame = hud.hatchAnimFrame
	local label = hud.hatchResultLabel

	frame.Visible = true
	frame.BackgroundColor3 = rarity.color
	frame.BackgroundTransparency = 0.3
	frame.Size = UDim2.new(0, 50, 0, 50)
	frame.Position = UDim2.new(0.5, -25, 0.5, -25)

	label.Text = ""
	label.TextColor3 = rarity.color

	-- Expand
	TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 300, 0, 300),
		Position = UDim2.new(0.5, -150, 0.5, -150),
		BackgroundTransparency = 0.05,
	}):Play()

	task.delay(0.45, function()
		label.Text = string.format("%s\n[%s]", def.name, result.rarity)
	end)

	task.delay(2.2, function()
		TweenService:Create(frame, TweenInfo.new(0.3), {
			BackgroundTransparency = 1,
		}):Play()
		label.TextTransparency = 1
		task.delay(0.3, function()
			frame.Visible = false
			label.TextTransparency = 0
		end)
	end)
end

-- ============ Toggles ============
function UIBuilder.toggleInventory(hud: HUD)
	hud.invFrame.Visible = not hud.invFrame.Visible
	if hud.invFrame.Visible then
		hud.zoneFrame.Visible = false
	end
end

function UIBuilder.toggleZones(hud: HUD)
	hud.zoneFrame.Visible = not hud.zoneFrame.Visible
	if hud.zoneFrame.Visible then
		hud.invFrame.Visible = false
	end
end

return UIBuilder
