# LEG BATTLES — Полный дизайн-документ

## Концепция
Ноговые битвы на арене. Игроки пинают друг друга, сбрасывают с платформ, открывают новую обувь со способностями. Прямой конкурент Slap Battles, но вместо перчаток — ноги.

## Ключевые механики

### 1. Kick-система (ядро игры)
- ЛКМ — удар ногой (cd 0.8с)
- Задержка кнопки — заряженный удар (отброс ×2, cd 1.5с)
- Hitbox перед персонажем, дальность 8 стадов
- Отброс по вектору от атакующего к цели
- Knockback scaling: чем дальше летишь, тем быстрее падаешь
- Удар в прыжке = +50% отброса
- Удар сзади = крит ×1.5

### 2. Обувь (вместо перчаток)
Каждая обувь — уникальная способность. Стартовая: обычные кроссовки.

| # | Обувь | Rarity | Способность | Цена |
|---|-------|--------|-------------|------|
| 1 | Кроссовки | Старт | Нет (база) | 0 |
| 2 | Кеды-прыгуны | Common | Двойной прыжок | 100 kills |
| 3 | Ботинки-щиты | Common | Блок (ПКМ) снижает отброс 50% | 250 kills |
| 4 | Кроссы-ракеты | Uncommon | Рывок вперёд (Shift), knockback ×1.3 | 500 kills |
| 5 | Ледяные ботинки | Uncommon | Удар замораживает 1с (медленный спад) | 750 kills |
| 6 | Магнитки | Rare | Притягивает цель к тебе при ударе | 1500 kills |
| 7 | Прыгучие сапоги | Rare | Высокий прыжок + падение = AoE удар | 2500 kills |
| 8 | Фазовые тапки | Epic | Рывок сквозь игроков (0.5с неуязвимости) | 5000 kills |
| 9 | Штормовые берцы | Epic | Удар молнии по области (3 таргета) | 8000 kills |
| 10 | Драконьи лапы | Legendary | Полёт 3с + удар в полёте | 15000 kills |
| 11 | Хроно-сапоги | Mythic | Замедляет время всех вокруг 2с | 30000 kills |
| 12 | Бог ноги | Cosmic | Все способности сразу + отброс ×2 | 100000 kills |

### 3. Арена
- Основная платформа 100×100, 4 ямы по углам (сброс = смерть)
- 3 уровня высоты (платформы, лестницы, трамплины)
- 2 трамплина (бойнста)
- Центральная яма-фонтан (периодически открывается)
- Спавн-щиты 2с после респавна
- Офф-поинты: за пределами карты = респавн

### 4. Боевая система
- HP: 100, восстановление 5/сек вне боя 3с
- Урон от кика: 25 базовый (не убивает 1 ударом — 4 удара)
- Отброс: базовый 40 стад/сек, заряженный 80
- Смерть = вылет за карту или HP ≤ 0
- Kill = +1 kill, жертва респавн через 3с
- Серия (streak): 3/5/10 подряд — бонус к счётчику

### 5. Прогрессия
- Kills — валюта (трекаются в DataStore)
- Магазин обуви (UI)
- Уровень игрока (XP за кики/убийства) — косметика
- Таблица лидеров (Leaderstats: Kills, Wins, Level)
- Wins: выжить 60с в "Last Standing" режиме раз в 5 мин

### 6. Режимы
- **Free For All** (основной) — все против всех
- **Teams** (потом) — 2 команды
- **Last Standing** — событие каждые 5 мин, кто выжил = Wins

### 7. UI/HUD
- HP бар
- Kill counter
- Кулдауны способностей (иконки)
- Магазин обуви (Tab)
- Kill feed (правый верх)
- Таблица лидеров (та самая Roblox)
- Streak-уведомления

## Техническая архитектура

```
LegBattles/
├── default.project.json
├── README.md
└── src/
    ├── shared/
    │   ├── Config.luau          — все числа
    │   ├── ShoeDatabase.luau    — каталог обуви
    │   ├── AbilityTypes.luau    — типы способностей
    │   └── Util.luau            — хелперы
    ├── server/
    │   ├── init.server.luau     — bootstrap, remotes, мир
    │   ├── DataService.luau     — DataStore kills/wins/owned shoes
    │   ├── CombatService.luau   — kick, hitbox, knockback, damage
    │   ├── AbilityService.luau  — активные способности
    │   ├── ArenaService.luau    — построение карты
    │   ├── KillService.luau     — смерти, kills, streaks, respawn
    │   ├── ShopService.luau     — покупка обуви
    │   └── EventService.luau    — Last Standing ивенты
    └── client/
        ├── init.client.luau     — input, camera, remote подписки
        ├── CombatClient.luau    — визуал удара, таймеры
        ├── AbilityClient.luau   — HUD кулдаунов, активация
        └── UIBuilder.luau       — весь UI кодом
```

## Remotes
```
Kick (RemoteEvent)         — client → server: удар
Ability (RemoteEvent)      — client → server: активация способности
Block (RemoteEvent)        — client → server: блок
BuyShoe (RemoteEvent)      — client → server: покупка
EquipShoe (RemoteEvent)    — client → server: экипировка
GetData (RemoteFunction)   — client → server: снапшот
DataChanged (RemoteEvent)  — server → client: дельта
KillFeed (RemoteEvent)     — server → всем: kill feed
Notify (RemoteEvent)       — server → client: тосты
AbilityCooldown (RemoteEvent) — server → client: кулдаун
```

## Установка
- install_to_command_bar.lua (Command Bar)
- CrystalisInstaller.lua (плагин) — тот же паттерн
