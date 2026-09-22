# CRYSTALIS — Pet Simulator на Roblox (с нуля)

Уникальный симулятор петей с кристаллической вселенной. Не клон Pet Sim — своя концепция.

## Концепция

Мир расколот на призматические зоны. Ты добываешь **люмены** (свет-валюта), вылупляешь **кристальных питомцев** из 5 стихий, сливаешь их, прокачиваешь и открываешь новые зоны.

### Уникальные механики

| Механика | Описание |
|---|---|
| 💎 Люмены | Валюта — единицы света, не монеты |
| 🔮 Кристаллизация | Пети растут, впитывая кристаллы |
| ⭐ Слияние (Fusion) | 2 одинаковых пети → 1 звёздная версия |
| 🌋 5 стихий | Огонь / Лёд / Природа / Свет / Тьма |
| 🗺 5 зон | От Радужной Луговины до Сердца Призмы |
| ↻ Ребёрс | Сброс за вечные множители |
| 🥚 Редкости | Common → Cosmic (7 уровней) |
| 🐾 Процедурные пети | Модельки строятся из Part'ов, без мешей |

## Структура

```
PrismPetSim/
├── default.project.json      # Rojo-конфиг
├── README.md
└── src/
    ├── shared/               # Общие модули (client + server)
    │   ├── Config.luau       # Вся балансировка в одном файле
    │   ├── PetDatabase.luau  # Каталог петей + рецепты моделей
    │   ├── RarityConfig.luau # Редкости, цвета, статы
    │   └── Util.luau         # Хелперы
    ├── server/               # Серверная логика
    │   ├── init.server.luau  # Точка входа
    │   ├── DataService.luau  # DataStore, load/save
    │   ├── PetService.luau   # Экипировка, слияние, множители
    │   ├── HatchService.luau # Вылупление яиц
    │   ├── ZoneService.luau  # Открытие зон
    │   ├── RebirthService.luau
    │   ├── MineService.luau  # Добыча кристаллов
    │   └── PetModelBuilder.luau  # Процедурные модельки
    └── client/               # Клиентский UI
        ├── init.client.luau  # Точка входа
        └── UIBuilder.luau    # Весь HUD строится кодом
```

## Как запустить

### Вариант 1: Rojo (рекомендуется)

```bash
# Установи Rojo: https://rojo.space/docs/v7/getting-started/installation/
rojo serve default.project.json
```

Затем в Roblox Studio: Rojo plugin → Connect.

### Вариант 2: Ручной (без Rojo)

1. Создай **Place** в Roblox Studio
2. В `ReplicatedStorage` → `Shared` (Folder) — скопируй все `.luau` из `src/shared/`
3. В `ServerScriptService` → `Server` (Script) — вставь `init.server.luau`, рядом положи остальные серверные модули как **ModuleScript'ы**
4. В `StarterPlayer → StarterPlayerScripts` → `Client` (LocalScript) — `init.client.luau`, рядом `UIBuilder` как ModuleScript
5. Play → всё построится автоматически

## Балансировка

Все числа в `src/shared/Config.luau`:

- `HATCH_BASE_COST`, `HATCH_COST_GROWTH` — цена яиц
- `ZONES` — зоны, стоимость, множители, шансы редкостей
- `REBIRTH_*` — ребёрс
- `MAX_PET_SLOTS`, `INVENTORY_CAP` — лимиты
- `MINE_*` — добыча

## Пети

18 питомей от Common до Cosmic. Каждый имеет:
- Стихию (5 типов)
- Уникальный пассивный навык
- Процедурную модельку (Part'ы, аксессуары, частицы-ауры)
- Систему звёзд слияния (до ★6)

## Лицензия

Свободно для использования в своих проектах.
