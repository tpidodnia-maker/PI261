--!strict
-- Pet catalogue. Each pet has a procedural model recipe (see PetModelBuilder)
-- so no mesh imports are needed — everything is built from Parts at runtime.

export type PetDef = {
	id: string,
	name: string,
	rarity: string,
	element: string,
	basePower: number,          -- base lumen multiplier contribution
	passive: string,            -- description shown in UI
	recipe: {                   -- procedural build recipe
		bodyColor: Color3,
		bodyShape: "Ball" | "Block" | "Wedge" | "Cylinder",
		bodySize: Vector3,
		headColor: Color3,
		headSize: Vector3,
		eyeColor: Color3,
		eyeStyle: "Round" | "Glow" | "Slit",
		accessory: string?,     -- "Horns" | "Wings" | "Crown" | "Crystal" | "None" | nil
		aura: string?,          -- particle color name
	},
}

local Pets: { [string]: PetDef } = {}

local function add(def: PetDef)
	Pets[def.id] = def
end

-- ============ COMMON ============
add({
	id = "spark", name = "Искрин", rarity = "Common", element = "Light",
	basePower = 1.0,
	passive = "Светится в темноте",
	recipe = {
		bodyColor = Color3.fromRGB(255, 235, 150),
		bodyShape = "Ball", bodySize = Vector3.new(1.2, 1.2, 1.2),
		headColor = Color3.fromRGB(255, 245, 190),
		headSize = Vector3.new(0.9, 0.9, 0.9),
		eyeColor = Color3.fromRGB(60, 60, 60),
		eyeStyle = "Round",
		accessory = "None", aura = "Light",
	},
})
add({
	id = "pebble", name = "Камешек", rarity = "Common", element = "Nature",
	basePower = 1.0,
	passive = "Устойчив к ударам",
	recipe = {
		bodyColor = Color3.fromRGB(150, 140, 120),
		bodyShape = "Block", bodySize = Vector3.new(1.4, 1.0, 1.4),
		headColor = Color3.fromRGB(170, 160, 140),
		headSize = Vector3.new(1.0, 0.8, 1.0),
		eyeColor = Color3.fromRGB(40, 40, 40),
		eyeStyle = "Round",
		accessory = "None",
	},
})
add({
	id = "flit", name = "Стрекозка", rarity = "Common", element = "Nature",
	basePower = 1.1,
	passive = "Быстрый полёт",
	recipe = {
		bodyColor = Color3.fromRGB(100, 200, 160),
		bodyShape = "Wedge", bodySize = Vector3.new(1.0, 0.8, 1.6),
		headColor = Color3.fromRGB(120, 220, 180),
		headSize = Vector3.new(0.7, 0.7, 0.7),
		eyeColor = Color3.fromRGB(20, 20, 20),
		eyeStyle = "Glow",
		accessory = "Wings", aura = "Nature",
	},
})

-- ============ UNCOMMON ============
add({
	id = "cinder", name = "Угольёк", rarity = "Uncommon", element = "Fire",
	basePower = 1.5,
	passive = "Согревает рядом стоящих",
	recipe = {
		bodyColor = Color3.fromRGB(255, 120, 50),
		bodyShape = "Ball", bodySize = Vector3.new(1.4, 1.3, 1.4),
		headColor = Color3.fromRGB(255, 150, 70),
		headSize = Vector3.new(1.0, 0.9, 1.0),
		eyeColor = Color3.fromRGB(255, 240, 100),
		eyeStyle = "Glow",
		accessory = "Horns", aura = "Fire",
	},
})
add({
	id = "frostpup", name = "Морозик", rarity = "Uncommon", element = "Ice",
	basePower = 1.5,
	passive = "Замедляет врагов льдом",
	recipe = {
		bodyColor = Color3.fromRGB(170, 220, 255),
		bodyShape = "Ball", bodySize = Vector3.new(1.3, 1.3, 1.3),
		headColor = Color3.fromRGB(200, 235, 255),
		headSize = Vector3.new(1.0, 0.9, 1.0),
		eyeColor = Color3.fromRGB(60, 140, 255),
		eyeStyle = "Slit",
		accessory = "Crystal", aura = "Ice",
	},
})
add({
	id = "sprout", name = "Росток", rarity = "Uncommon", element = "Nature",
	basePower = 1.6,
	passive = "Увеличивает урожай кристаллов",
	recipe = {
		bodyColor = Color3.fromRGB(90, 200, 90),
		bodyShape = "Cylinder", bodySize = Vector3.new(1.1, 1.5, 1.1),
		headColor = Color3.fromRGB(110, 220, 110),
		headSize = Vector3.new(1.0, 1.0, 1.0),
		eyeColor = Color3.fromRGB(30, 80, 30),
		eyeStyle = "Round",
		accessory = "Crystal", aura = "Nature",
	},
})

-- ============ RARE ============
add({
	id = "emberfox", name = "Пепелис", rarity = "Rare", element = "Fire",
	basePower = 2.5,
	passive = "Шанс критического удара +10%",
	recipe = {
		bodyColor = Color3.fromRGB(255, 90, 40),
		bodyShape = "Block", bodySize = Vector3.new(1.5, 1.2, 1.8),
		headColor = Color3.fromRGB(255, 120, 60),
		headSize = Vector3.new(1.1, 1.0, 1.1),
		eyeColor = Color3.fromRGB(255, 250, 120),
		eyeStyle = "Slit",
		accessory = "Horns", aura = "Fire",
	},
})
add({
	id = "glacier", name = "Ледышка", rarity = "Rare", element = "Ice",
	basePower = 2.5,
	passive = "Снижает стоимость хэтча на 5%",
	recipe = {
		bodyColor = Color3.fromRGB(140, 200, 255),
		bodyShape = "Wedge", bodySize = Vector3.new(1.4, 1.4, 1.8),
		headColor = Color3.fromRGB(170, 220, 255),
		headSize = Vector3.new(1.0, 1.0, 1.0),
		eyeColor = Color3.fromRGB(40, 100, 255),
		eyeStyle = "Glow",
		accessory = "Crystal", aura = "Ice",
	},
})
add({
	id = "lumenowl", name = "Светлячок", rarity = "Rare", element = "Light",
	basePower = 2.8,
	passive = "Увеличивает Luck на 15%",
	recipe = {
		bodyColor = Color3.fromRGB(255, 240, 170),
		bodyShape = "Ball", bodySize = Vector3.new(1.3, 1.5, 1.3),
		headColor = Color3.fromRGB(255, 250, 200),
		headSize = Vector3.new(1.1, 1.0, 1.1),
		eyeColor = Color3.fromRGB(255, 220, 60),
		eyeStyle = "Glow",
		accessory = "Crown", aura = "Light",
	},
})

-- ============ EPIC ============
add({
	id = "nightshade", name = "Теневик", rarity = "Epic", element = "Dark",
	basePower = 4.0,
	passive = "Крадёт 1% лютменов с каждого клика",
	recipe = {
		bodyColor = Color3.fromRGB(80, 40, 120),
		bodyShape = "Ball", bodySize = Vector3.new(1.6, 1.5, 1.6),
		headColor = Color3.fromRGB(100, 50, 150),
		headSize = Vector3.new(1.2, 1.1, 1.2),
		eyeColor = Color3.fromRGB(255, 60, 60),
		eyeStyle = "Slit",
		accessory = "Horns", aura = "Dark",
	},
})
add({
	id = "aurora", name = "Аврора", rarity = "Epic", element = "Light",
	basePower = 4.2,
	passive = "Все стихии получают +10%",
	recipe = {
		bodyColor = Color3.fromRGB(180, 255, 200),
		bodyShape = "Cylinder", bodySize = Vector3.new(1.4, 1.8, 1.4),
		headColor = Color3.fromRGB(200, 255, 220),
		headSize = Vector3.new(1.1, 1.1, 1.1),
		eyeColor = Color3.fromRGB(255, 255, 200),
		eyeStyle = "Glow",
		accessory = "Wings", aura = "Light",
	},
})
add({
	id = "magmagolem", name = "Лавокамень", rarity = "Epic", element = "Fire",
	basePower = 4.5,
	passive = "Увеличивает добычу кристаллов на 20%",
	recipe = {
		bodyColor = Color3.fromRGB(200, 60, 20),
		bodyShape = "Block", bodySize = Vector3.new(1.8, 1.6, 1.8),
		headColor = Color3.fromRGB(220, 80, 30),
		headSize = Vector3.new(1.3, 1.2, 1.3),
		eyeColor = Color3.fromRGB(255, 200, 50),
		eyeStyle = "Glow",
		accessory = "Crystal", aura = "Fire",
	},
})

-- ============ LEGENDARY ============
add({
	id = "prismdragon", name = "Призмадракон", rarity = "Legendary", element = "Light",
	basePower = 7.0,
	passive = "+25% ко всем бонусам",
	recipe = {
		bodyColor = Color3.fromRGB(255, 200, 255),
		bodyShape = "Wedge", bodySize = Vector3.new(2.0, 1.6, 2.6),
		headColor = Color3.fromRGB(255, 220, 255),
		headSize = Vector3.new(1.4, 1.3, 1.6),
		eyeColor = Color3.fromRGB(255, 100, 255),
		eyeStyle = "Slit",
		accessory = "Wings", aura = "Light",
	},
})
add({
	id = "voidwalker", name = "Ходок Пустоты", rarity = "Legendary", element = "Dark",
	basePower = 7.5,
	passive = "Игнорирует 50% сопротивления",
	recipe = {
		bodyColor = Color3.fromRGB(40, 10, 70),
		bodyShape = "Block", bodySize = Vector3.new(1.6, 2.2, 1.6),
		headColor = Color3.fromRGB(60, 20, 100),
		headSize = Vector3.new(1.2, 1.4, 1.2),
		eyeColor = Color3.fromRGB(200, 50, 255),
		eyeStyle = "Glow",
		accessory = "Crown", aura = "Dark",
	},
})
add({
	id = "frostgiant", name = "Морозный Великан", rarity = "Legendary", element = "Ice",
	basePower = 7.2,
	passive = "Замораживает добычу врагов",
	recipe = {
		bodyColor = Color3.fromRGB(160, 210, 255),
		bodyShape = "Block", bodySize = Vector3.new(2.2, 2.4, 2.2),
		headColor = Color3.fromRGB(180, 230, 255),
		headSize = Vector3.new(1.5, 1.5, 1.5),
		eyeColor = Color3.fromRGB(80, 180, 255),
		eyeStyle = "Slit",
		accessory = "Horns", aura = "Ice",
	},
})

-- ============ MYTHIC ============
add({
	id = "phoenix", name = "Феникс Пустоты", rarity = "Mythic", element = "Fire",
	basePower = 12.0,
	passive = "Воскрешает с 50% HP",
	recipe = {
		bodyColor = Color3.fromRGB(255, 60, 80),
		bodyShape = "Wedge", bodySize = Vector3.new(1.8, 1.6, 2.4),
		headColor = Color3.fromRGB(255, 100, 120),
		headSize = Vector3.new(1.3, 1.2, 1.5),
		eyeColor = Color3.fromRGB(255, 255, 80),
		eyeStyle = "Glow",
		accessory = "Wings", aura = "Fire",
	},
})
add({
	id = "chronobeast", name = "Хронозверь", rarity = "Mythic", element = "Dark",
	basePower = 13.0,
	passive = "Ускоряет все кулдауны на 20%",
	recipe = {
		bodyColor = Color3.fromRGB(30, 30, 60),
		bodyShape = "Cylinder", bodySize = Vector3.new(1.8, 2.0, 1.8),
		headColor = Color3.fromRGB(50, 50, 90),
		headSize = Vector3.new(1.4, 1.4, 1.4),
		eyeColor = Color3.fromRGB(100, 255, 255),
		eyeStyle = "Glow",
		accessory = "Crown", aura = "Dark",
	},
})

-- ============ COSMIC ============
add({
	id = "singularity", name = "Сингулярность", rarity = "Cosmic", element = "Dark",
	basePower = 25.0,
	passive = "Все множители ×2",
	recipe = {
		bodyColor = Color3.fromRGB(10, 10, 20),
		bodyShape = "Ball", bodySize = Vector3.new(2.4, 2.4, 2.4),
		headColor = Color3.fromRGB(30, 30, 50),
		headSize = Vector3.new(1.6, 1.6, 1.6),
		eyeColor = Color3.fromRGB(255, 255, 255),
		eyeStyle = "Glow",
		accessory = "Crown", aura = "Light",
	},
})

-- ---- lookup helpers ----

function Pets.get(id: string): PetDef?
	return Pets[id]
end

function Pets.byRarity(rarity: string): { PetDef }
	local out = {}
	for _, def in Pets do
		if def.rarity == rarity then
			table.insert(out, def)
		end
	end
	return out
end

function Pets.all(): { PetDef }
	local out = {}
	for _, def in Pets do
		table.insert(out, def)
	end
	return out
end

return Pets
