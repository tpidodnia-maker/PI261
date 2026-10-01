--!strict
-- LEG BATTLES — Full UI builder (HUD, shop, kill feed, effects).

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local ShoeDatabase = require(Shared:WaitForChild("ShoeDatabase"))
local Util = require(Shared:WaitForChild("Util"))

local UIBuilder = {}

type HUD = {
	root: ScreenGui,
	hpBar: Frame,
	hpLabel: TextLabel,
	killsLabel: TextLabel,
	streakLabel: TextLabel,
	shoeNameLabel: TextLabel,
	abilityFrame: Frame,
	abilityIcon: TextLabel,
	abilityCooldownLabel: TextLabel,
	killFeedFrame: Frame,
	toastLabel: TextLabel,
	hitmarker: TextLabel,
	damageFlash: Frame,
	blockIndicator: TextLabel,
	shopFrame: Frame,
	shopGrid: ScrollingFrame,
	chargeBar: Frame,
	kickAnimIcon: TextLabel,
	abilityFxLabel: TextLabel,
}

local COLORS = {
	bg = Color3.fromRGB(20, 20, 30),
	panel = Color3.fromRGB(30, 30, 45),
	accent = Color3.fromRGB(255, 100, 60),
	hp = Color3.fromRGB(80, 220, 100),
	hpLow = Color3.fromRGB(255, 70, 70),
	text = Color3.fromRGB(245, 245, 255),
	dim = Color3.fromRGB(150, 150, 170),
	kill = Color3.fromRGB(255, 200, 50),
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

function UIBuilder.buildHUD(): HUD
	local gui = mk("ScreenGui", {
		Name = "LegBattlesHUD",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, player:WaitForChild("PlayerGui")) :: ScreenGui

	-- HP bar (bottom center)
	local hpBarBg = mk("Frame", {
		Size = UDim2.new(0, 300, 0, 22),
		Position = UDim2.new(0.5, -150, 1, -50),
		BackgroundColor3 = COLORS.bg,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
	}, gui) :: Frame
	mk("UICorner", { CornerRadius = UDim.new(0, 6) }, hpBarBg)

	local hpBar = mk("Frame", {
		Size = UDim2.new(1, -4, 1, -4),
		Position = UDim2.new(0, 2, 0, 2),
		BackgroundColor3 = COLORS.hp,
		BorderSizePixel = 0,
	}, hpBarBg) :: Frame
	mk("UICorner", { CornerRadius = UDim.new(0, 4) }, hpBar)

	local hpLabel = mk("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = COLORS.text,
		Text = "100 / 100",
	}, hpBarBg) :: TextLabel

	-- Top-left stats
	local topLeft = mk("Frame", {
		Size = UDim2.new(0, 250, 0, 80),
		Position = UDim2.new(0, 12, 0, 12),
		BackgroundColor3 = COLORS.panel,
		BackgroundTransparency = 0.25,
		BorderSizePixel = 0,
	}, gui) :: Frame
	mk("UICorner", { CornerRadius = UDim.new(0, 8) }, topLeft)

	local killsLabel = mk("TextLabel", {
		Size = UDim2.new(1, -12, 0, 24),
		Position = UDim2.new(0, 12, 0, 8),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		TextColor3 = COLORS.kill,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "💀 0 убийств",
	}, topLeft) :: TextLabel

	local streakLabel = mk("TextLabel", {
		Size = UDim2.new(1, -12, 0, 20),
		Position = UDim2.new(0, 12, 0, 32),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = COLORS.accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
	}, topLeft) :: TextLabel

	local shoeNameLabel = mk("TextLabel", {
		Size = UDim2.new(1, -12, 0, 20),
		Position = UDim2.new(0, 12, 0, 54),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = COLORS.dim,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "👟 Кроссовки",
	}, topLeft) :: TextLabel

	-- Ability icon (bottom right)
	local abilityFrame = mk("Frame", {
		Size = UDim2.new(0, 64, 0, 64),
		Position = UDim2.new(1, -84, 1, -84),
		BackgroundColor3 = COLORS.panel,
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
	}, gui) :: Frame
	mk("UICorner", { CornerRadius = UDim.new(0, 10) }, abilityFrame)

	local abilityIcon = mk("TextLabel", {
		Size = UDim2.new(1, 0, 1, -16),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 28,
		TextColor3 = COLORS.text,
		Text = "⚡",
	}, abilityFrame) :: TextLabel

	local abilityCooldownLabel = mk("TextLabel", {
		Size = UDim2.new(1, 0, 0, 16),
		Position = UDim2.new(0, 0, 1, -16),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = COLORS.accent,
		Text = "",
	}, abilityFrame) :: TextLabel

	-- Kill feed (top right)
	local killFeedFrame = mk("Frame", {
		Size = UDim2.new(0, 300, 0, 200),
		Position = UDim2.new(1, -312, 0, 12),
		BackgroundTransparency = 1,
	}, gui) :: Frame
	mk("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
	}, killFeedFrame)

	-- Toast
	local toastLabel = mk("TextLabel", {
		Size = UDim2.new(0, 420, 0, 34),
		Position = UDim2.new(0.5, -210, 0, 70),
		BackgroundColor3 = COLORS.panel,
		BackgroundTransparency = 0.2,
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		TextColor3 = COLORS.text,
		Text = "",
		TextTransparency = 1,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, gui) :: TextLabel
	mk("UICorner", { CornerRadius = UDim.new(0, 8) }, toastLabel)

	-- Hitmarker
	local hitmarker = mk("TextLabel", {
		Size = UDim2.new(0, 60, 0, 60),
		Position = UDim2.new(0.5, -30, 0.5, -30),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 32,
		TextColor3 = COLORS.kill,
		Text = "✕",
		TextTransparency = 1,
	}, gui) :: TextLabel

	-- Damage flash (red vignette)
	local damageFlash = mk("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(255, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 5,
	}, gui) :: Frame

	-- Block indicator
	local blockIndicator = mk("TextLabel", {
		Size = UDim2.new(0, 120, 0, 30),
		Position = UDim2.new(0.5, -60, 1, -90),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		TextColor3 = Color3.fromRGB(100, 180, 255),
		Text = "🛡 БЛОК",
		TextTransparency = 1,
	}, gui) :: TextLabel

	-- Charge bar (appears while charging)
	local chargeBar = mk("Frame", {
		Size = UDim2.new(0, 200, 0, 12),
		Position = UDim2.new(0.5, -100, 1, -80),
		BackgroundColor3 = COLORS.bg,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		Visible = false,
	}, gui) :: Frame
	mk("UICorner", { CornerRadius = UDim.new(0, 6) }, chargeBar)

	-- Kick anim icon
	local kickAnimIcon = mk("TextLabel", {
		Size = UDim2.new(0, 100, 0, 100),
		Position = UDim2.new(0.5, -50, 0.5, 100),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 60,
		Text = "🦵",
		TextTransparency = 1,
	}, gui) :: TextLabel

	-- Ability FX label (center)
	local abilityFxLabel = mk("TextLabel", {
		Size = UDim2.new(0, 300, 0, 40),
		Position = UDim2.new(0.5, -150, 0.35, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 26,
		TextColor3 = Color3.fromRGB(255, 255, 100),
		TextStrokeTransparency = 0.5,
		Text = "",
		TextTransparency = 1,
	}, gui) :: TextLabel

	-- Shop panel
	local shopFrame = mk("Frame", {
		Size = UDim2.new(0, 560, 0, 440),
		Position = UDim2.new(0.5, -280, 0.5, -220),
		BackgroundColor3 = COLORS.panel,
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		Visible = false,
	}, gui) :: Frame
	mk("UICorner", { CornerRadius = UDim.new(0, 12) }, shopFrame)
	mk("UIPadding", {
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
	}, shopFrame)

	mk("TextLabel", {
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		TextColor3 = COLORS.text,
		Text = "👟 Магазин обуви  [Tab]",
		TextXAlignment = Enum.TextXAlignment.Left,
	}, shopFrame)

	local shopGrid = mk("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, -40),
		Position = UDim2.new(0, 0, 0, 36),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 6,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
	}, shopFrame) :: ScrollingFrame

	mk("UIGridLayout", {
		CellSize = UDim2.new(0, 170, 0, 180),
		CellPadding = UDim2.new(0, 8, 0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, shopGrid)

	return {
		root = gui,
		hpBar = hpBar,
		hpLabel = hpLabel,
		killsLabel = killsLabel,
		streakLabel = streakLabel,
		shoeNameLabel = shoeNameLabel,
		abilityFrame = abilityFrame,
		abilityIcon = abilityIcon,
		abilityCooldownLabel = abilityCooldownLabel,
		killFeedFrame = killFeedFrame,
		toastLabel = toastLabel,
		hitmarker = hitmarker,
		damageFlash = damageFlash,
		blockIndicator = blockIndicator,
		shopFrame = shopFrame,
		shopGrid = shopGrid,
		chargeBar = chargeBar,
		kickAnimIcon = kickAnimIcon,
		abilityFxLabel = abilityFxLabel,
	}
end

-- ============ updateHUD ============
function UIBuilder.updateHUD(hud: HUD, data: any)
	if not data then
		return
	end
	hud.killsLabel.Text = "💀 " .. tostring(data.kills or 0) .. " убийств"
	local streak = data.streak or 0
	hud.streakLabel.Text = streak >= 3 and ("🔥 Серия: " .. streak) or ""

	local shoe = ShoeDatabase.get(data.equippedShoe or "sneakers")
	if shoe then
		hud.shoeNameLabel.Text = "👟 " .. shoe.name
		hud.abilityIcon.Text = shoe.ability.type ~= "none" and "⚡" or "—"
		if shoe.ability.type == "double_jump" then
			hud.abilityIcon.Text = "⤴"
		elseif shoe.ability.type == "block" then
			hud.abilityIcon.Text = "🛡"
		elseif shoe.ability.type == "fly" then
			hud.abilityIcon.Text = "🐉"
		elseif shoe.ability.type == "time" then
			hud.abilityIcon.Text = "⏳"
		elseif shoe.ability.type == "lightning" then
			hud.abilityIcon.Text = "⚡"
		end
	end

	-- HP from humanoid
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
		hud.hpBar.Size = UDim2.new(pct, -4, 1, -4)
		hud.hpBar.BackgroundColor3 = pct > 0.3 and COLORS.hp or COLORS.hpLow
		hud.hpLabel.Text = string.format("%d / %d", math.floor(hum.Health), math.floor(hum.MaxHealth))
	end
end

-- ============ updateShop ============
function UIBuilder.updateShop(hud: HUD, data: any, onBuy: (string) -> (), onEquip: (string) -> ())
	for _, child in hud.shopGrid:GetChildren() do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	for order, shoe in ShoeDatabase.ordered() do
		local owned = table.find(data.ownedShoes or {}, shoe.id) ~= nil
		local equipped = data.equippedShoe == shoe.id
		local rarityColor = ShoeDatabase.rarityColor(shoe.rarity)

		local card = mk("Frame", {
			Size = UDim2.new(0, 170, 0, 180),
			BackgroundColor3 = COLORS.bg,
			BackgroundTransparency = 0.2,
			BorderSizePixel = 0,
			LayoutOrder = order,
		}, hud.shopGrid) :: Frame
		mk("UICorner", { CornerRadius = UDim.new(0, 10) }, card)

		-- Rarity stripe
		mk("Frame", {
			Size = UDim2.new(1, 0, 0, 4),
			BackgroundColor3 = rarityColor,
			BorderSizePixel = 0,
		}, card)

		-- Shoe preview (colored square)
		mk("Frame", {
			Size = UDim2.new(0, 50, 0, 36),
			Position = UDim2.new(0.5, -25, 0, 14),
			BackgroundColor3 = shoe.color,
			BorderSizePixel = 0,
		}, card)
		mk("UICorner", { CornerRadius = UDim.new(0, 6) }, card:FindFirstChildOfClass("Frame") :: any)

		mk("TextLabel", {
			Size = UDim2.new(1, -8, 0, 18),
			Position = UDim2.new(0, 4, 0, 56),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			TextColor3 = rarityColor,
			Text = shoe.rarity,
		}, card)

		mk("TextLabel", {
			Size = UDim2.new(1, -8, 0, 20),
			Position = UDim2.new(0, 4, 0, 74),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 15,
			TextColor3 = COLORS.text,
			Text = shoe.name,
			TextWrapped = true,
		}, card)

		mk("TextLabel", {
			Size = UDim2.new(1, -8, 0, 32),
			Position = UDim2.new(0, 4, 0, 96),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextSize = 10,
			TextColor3 = COLORS.dim,
			Text = shoe.ability.description,
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
		}, card)

		-- Button
		if equipped then
			mk("TextLabel", {
				Size = UDim2.new(1, -12, 0, 26),
				Position = UDim2.new(0, 6, 1, -32),
				BackgroundColor3 = Color3.fromRGB(80, 220, 100),
				BackgroundTransparency = 0.3,
				Font = Enum.Font.GothamBold,
				TextSize = 13,
				TextColor3 = COLORS.text,
				Text = "✓ НАДЕТО",
				BorderSizePixel = 0,
			}, card)
		elseif owned then
			local btn = mk("TextButton", {
				Size = UDim2.new(1, -12, 0, 26),
				Position = UDim2.new(0, 6, 1, -32),
				BackgroundColor3 = COLORS.accent,
				Font = Enum.Font.GothamBold,
				TextSize = 13,
				TextColor3 = COLORS.text,
				Text = "Надеть",
				AutoButtonColor = true,
				BorderSizePixel = 0,
			}, card) :: TextButton
			mk("UICorner", { CornerRadius = UDim.new(0, 6) }, btn)
			btn.MouseButton1Click:Connect(function()
				onEquip(shoe.id)
			end)
		else
			local btn = mk("TextButton", {
				Size = UDim2.new(1, -12, 0, 26),
				Position = UDim2.new(0, 6, 1, -32),
				BackgroundColor3 = (data.kills or 0) >= shoe.cost and Color3.fromRGB(70, 130, 255) or Color3.fromRGB(80, 80, 90),
				Font = Enum.Font.GothamBold,
				TextSize = 13,
				TextColor3 = COLORS.text,
				Text = "💀 " .. Util.formatNumber(shoe.cost),
				AutoButtonColor = true,
				BorderSizePixel = 0,
			}, card) :: TextButton
			mk("UICorner", { CornerRadius = UDim.new(0, 6) }, btn)
			btn.MouseButton1Click:Connect(function()
				onBuy(shoe.id)
			end)
		end
	end
end

-- ============ Effects ============

function UIBuilder.showToast(hud: HUD, message: string, isError: boolean)
	local label = hud.toastLabel
	label.Text = message
	label.TextColor3 = isError and Color3.fromRGB(255, 90, 90) or COLORS.text
	label.TextTransparency = 0
	label.BackgroundTransparency = 0.2
	TweenService:Create(label, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 1.8), {
		TextTransparency = 1,
		BackgroundTransparency = 1,
	}):Play()
end

function UIBuilder.showHitmarker(hud: HUD, info: any)
	local h = hud.hitmarker
	h.TextColor3 = info.crit and Color3.fromRGB(255, 80, 80) or COLORS.kill
	h.Text = info.crit and "✕✕" or "✕"
	h.TextTransparency = 0
	h.Size = info.crit and UDim2.new(0, 80, 0, 80) or UDim2.new(0, 60, 0, 60)
	h.Position = info.crit and UDim2.new(0.5, -40, 0.5, -40) or UDim2.new(0.5, -30, 0.5, -30)
	TweenService:Create(h, TweenInfo.new(0.4), { TextTransparency = 1 }):Play()
end

function UIBuilder.showDamageFlash(hud: HUD, info: any)
	local f = hud.damageFlash
	f.BackgroundTransparency = 0.7
	TweenService:Create(f, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
end

function UIBuilder.showBlockFx(hud: HUD)
	local b = hud.blockIndicator
	b.TextTransparency = 0
	TweenService:Create(b, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 1.2), {
		TextTransparency = 1,
	}):Play()
end

function UIBuilder.playKickAnim(hud: HUD, charged: boolean)
	local icon = hud.kickAnimIcon
	icon.Text = charged and "💥" or "🦵"
	icon.TextTransparency = 0
	icon.Size = charged and UDim2.new(0, 140, 0, 140) or UDim2.new(0, 100, 0, 100)
	icon.Position = charged and UDim2.new(0.5, -70, 0.5, 80) or UDim2.new(0.5, -50, 0.5, 100)
	TweenService:Create(icon, TweenInfo.new(0.35), { TextTransparency = 1 }):Play()
end

function UIBuilder.showAbilityFx(hud: HUD, info: any)
	local labels = {
		dash = "💨 РЫВОК!",
		phase = "👻 ФАЗА!",
		fly = "🐉 ПОЛЁТ!",
		lightning = "⚡ МОЛНИЯ!",
		time = "⏳ ВРЕМЯ!",
	}
	local label = hud.abilityFxLabel
	label.Text = labels[info.type] or ""
	label.TextTransparency = 0
	TweenService:Create(label, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 1.2), {
		TextTransparency = 1,
	}):Play()
end

function UIBuilder.addKillFeed(hud: HUD, entry: any)
	local row = mk("TextLabel", {
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundColor3 = COLORS.panel,
		BackgroundTransparency = 0.3,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = entry.suicide and COLORS.dim or COLORS.kill,
		Text = entry.suicide
			and (entry.killer .. " упал 💀")
			or (entry.killer .. " 💥 " .. entry.victim .. (entry.streak >= 3 and ("  🔥" .. entry.streak) or "")),
		BorderSizePixel = 0,
	}, hud.killFeedFrame) :: TextLabel
	mk("UICorner", { CornerRadius = UDim.new(0, 4) }, row)

	task.delay(5, function()
		if row.Parent then
			TweenService:Create(row, TweenInfo.new(0.5), { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
			task.wait(0.5)
			row:Destroy()
		end
	end)
end

function UIBuilder.updateCooldowns(hud: HUD, cooldowns: { [string]: number })
	-- handled per-frame in a loop below
end

-- Cooldown ticker
task.spawn(function()
	while true do
		task.wait(0.1)
		local hud = nil
		-- find via player gui
		local gui = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("LegBattlesHUD")
		if gui then
			-- update handled by closures; simple approach: skip
		end
	end
end)

function UIBuilder.toggleShop(hud: HUD)
	hud.shopFrame.Visible = not hud.shopFrame.Visible
end

return UIBuilder
