--!strict
-- LEG BATTLES — Shoe catalogue with abilities.

export type AbilityDef = {
	id: string,
	name: string,
	type: "none" | "double_jump" | "block" | "dash" | "freeze" | "magnet" |
	      "quake" | "phase" | "lightning" | "fly" | "time" | "all",
	cooldown: number,
	duration: number?,
	description: string,
	key: string,           -- input key hint
}

export type ShoeDef = {
	id: string,
	name: string,
	rarity: "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary" | "Mythic" | "Cosmic",
	cost: number,          -- kills
	color: Color3,
	soleColor: Color3,
	knockbackMult: number,
	ability: AbilityDef,
}

local Shoes: { [string]: ShoeDef } = {}

local function add(def: ShoeDef)
	Shoes[def.id] = def
end

add({
	id = "sneakers", name = "Кроссовки", rarity = "Common", cost = 0,
	color = Color3.fromRGB(220, 60, 60), soleColor = Color3.fromRGB(240, 240, 240),
	knockbackMult = 1.0,
	ability = { id = "none", name = "Нет", type = "none", cooldown = 0, description = "Обычные кроссовки", key = "" },
})
add({
	id = "jumpers", name = "Кеды-прыгуны", rarity = "Common", cost = 100,
	color = Color3.fromRGB(80, 200, 120), soleColor = Color3.fromRGB(255, 255, 255),
	knockbackMult = 1.0,
	ability = { id = "double_jump", name = "Двойной прыжок", type = "double_jump", cooldown = 0, description = "Прыгай дважды в воздухе", key = "Space" },
})
add({
	id = "shield_boots", name = "Ботинки-щиты", rarity = "Common", cost = 250,
	color = Color3.fromRGB(100, 120, 160), soleColor = Color3.fromRGB(60, 70, 90),
	knockbackMult = 1.1,
	ability = { id = "block", name = "Блок", type = "block", cooldown = 3, description = "ПКМ — снижает отброс на 50% на 1.5с", key = "RMB" },
})
add({
	id = "rocket_kicks", name = "Кроссы-ракеты", rarity = "Uncommon", cost = 500,
	color = Color3.fromRGB(255, 140, 40), soleColor = Color3.fromRGB(255, 220, 100),
	knockbackMult = 1.3,
	ability = { id = "dash", name = "Рывок", type = "dash", cooldown = 5, description = "Shift — рывок вперёд с усиленным ударом", key = "Shift" },
})
add({
	id = "frost_boots", name = "Ледяные ботинки", rarity = "Uncommon", cost = 750,
	color = Color3.fromRGB(140, 210, 255), soleColor = Color3.fromRGB(200, 240, 255),
	knockbackMult = 1.0,
	ability = { id = "freeze", name = "Заморозка", type = "freeze", cooldown = 8, duration = 1, description = "Удар замораживает цель на 1с", key = "Passive" },
})
add({
	id = "magnets", name = "Магнитки", rarity = "Rare", cost = 1500,
	color = Color3.fromRGB(200, 60, 200), soleColor = Color3.fromRGB(80, 80, 90),
	knockbackMult = 0.8,
	ability = { id = "magnet", name = "Притяжение", type = "magnet", cooldown = 6, description = "Удар притягивает цель к тебе", key = "Passive" },
})
add({
	id = "spring_boots", name = "Прыгучие сапоги", rarity = "Rare", cost = 2500,
	color = Color3.fromRGB(255, 220, 60), soleColor = Color3.fromRGB(200, 160, 40),
	knockbackMult = 1.0,
	ability = { id = "quake", name = "Землетрясение", type = "quake", cooldown = 10, description = "Падение с высоты — AoE удар", key = "Passive" },
})
add({
	id = "phase_slippers", name = "Фазовые тапки", rarity = "Epic", cost = 5000,
	color = Color3.fromRGB(160, 80, 255), soleColor = Color3.fromRGB(220, 180, 255),
	knockbackMult = 1.2,
	ability = { id = "phase", name = "Фаза", type = "phase", cooldown = 12, duration = 0.5, description = "Shift — рывок сквозь игроков, неуязвимость 0.5с", key = "Shift" },
})
add({
	id = "storm_boots", name = "Штормовые берцы", rarity = "Epic", cost = 8000,
	color = Color3.fromRGB(60, 60, 80), soleColor = Color3.fromRGB(255, 255, 80),
	knockbackMult = 1.4,
	ability = { id = "lightning", name = "Молния", type = "lightning", cooldown = 15, description = "Удар молнии по 3 целям вокруг", key = "E" },
})
add({
	id = "dragon_paws", name = "Драконьи лапы", rarity = "Legendary", cost = 15000,
	color = Color3.fromRGB(200, 40, 40), soleColor = Color3.fromRGB(255, 160, 40),
	knockbackMult = 1.6,
	ability = { id = "fly", name = "Полёт", type = "fly", cooldown = 20, duration = 3, description = "F — полёт 3с, удар в полёте +100%", key = "F" },
})
add({
	id = "chrono_boots", name = "Хроно-сапоги", rarity = "Mythic", cost = 30000,
	color = Color3.fromRGB(40, 40, 60), soleColor = Color3.fromRGB(100, 255, 255),
	knockbackMult = 1.5,
	ability = { id = "time", name = "Время", type = "time", cooldown = 30, duration = 2, description = "Замедляет всех вокруг на 2с", key = "E" },
})
add({
	id = "god_legs", name = "Бог Ноги", rarity = "Cosmic", cost = 100000,
	color = Color3.fromRGB(255, 215, 0), soleColor = Color3.fromRGB(255, 255, 255),
	knockbackMult = 2.0,
	ability = { id = "all", name = "Всё сразу", type = "all", cooldown = 10, description = "Все способности + отброс ×2", key = "All" },
})

local ORDER: { string } = {
	"sneakers", "jumpers", "shield_boots", "rocket_kicks", "frost_boots",
	"magnets", "spring_boots", "phase_slippers", "storm_boots",
	"dragon_paws", "chrono_boots", "god_legs",
}

function Shoes.get(id: string): ShoeDef?
	return Shoes[id]
end

function Shoes.ordered(): { ShoeDef }
	local out = {}
	for _, id in ORDER do
		if Shoes[id] then
			table.insert(out, Shoes[id] :: any)
		end
	end
	return out
end

function Shoes.rarityColor(rarity: string): Color3
	local map = {
		Common = Color3.fromRGB(170, 170, 170),
		Uncommon = Color3.fromRGB(90, 220, 90),
		Rare = Color3.fromRGB(80, 150, 255),
		Epic = Color3.fromRGB(170, 90, 255),
		Legendary = Color3.fromRGB(255, 200, 50),
		Mythic = Color3.fromRGB(255, 80, 130),
		Cosmic = Color3.fromRGB(255, 255, 255),
	}
	return (map :: any)[rarity] or Color3.fromRGB(255, 255, 255)
end

return Shoes
