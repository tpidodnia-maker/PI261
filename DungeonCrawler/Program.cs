using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;

namespace DungeonCrawler;

class Player
{
    public string Name;
    public int HP;
    public int MaxHP;
    public int Attack;
    public int Defense;
    public int Gold;
    public int Potions;
    public int Floor;
    public int Kills;
    public string Weapon;
    public int WeaponBonus;

    public Player(string name)
    {
        Name = name;
        HP = 100;
        MaxHP = 100;
        Attack = 12;
        Defense = 3;
        Gold = 0;
        Potions = 3;
        Floor = 1;
        Kills = 0;
        Weapon = "Rusty Sword";
        WeaponBonus = 0;
    }

    public int TotalAttack => Attack + WeaponBonus;
}

class Monster
{
    public string Name;
    public string Icon;
    public int HP;
    public int MaxHP;
    public int Attack;
    public int Defense;
    public int GoldReward;
    public int XPReward;

    public Monster(string name, string icon, int hp, int attack, int defense, int gold, int xp)
    {
        Name = name;
        Icon = icon;
        HP = hp;
        MaxHP = hp;
        Attack = attack;
        Defense = defense;
        GoldReward = gold;
        XPReward = xp;
    }
}

class LootItem
{
    public string Name;
    public string Description;
    public int Value;

    public LootItem(string name, string desc, int value)
    {
        Name = name;
        Description = desc;
        Value = value;
    }
}

class Dungeon
{
    static Random rng = new();
    static Player player = null!;
    static bool gameOver = false;

    static readonly string[] fightArts =
    {
        @"
    ╔═══════════════════╗
    ║   FIGHT!          ║
    ╚═══════════════════╝",
        @"
      \\   ||
       \\  ||
        \\ ||
     [----]\\
     |    |//
     |    |/
     \\    |
      \\   |
       \\  |
        \\ |
         \\|
    ATTACK!"
    };

    static void Main()
    {
        Console.OutputEncoding = System.Text.Encoding.UTF8;
        Console.CursorVisible = false;

        ShowTitle();
        Console.Write("\n  Enter your name, adventurer: ");
        Console.CursorVisible = true;
        string name = Console.ReadLine() ?? "Hero";
        Console.CursorVisible = false;
        player = new Player(name);

        Console.Clear();
        ColorWrite($"\n  Welcome, {player.Name}! You descend into the Dark Dungeon...\n", ConsoleColor.Cyan);
        Thread.Sleep(1500);

        while (!gameOver)
        {
            ExploreFloor();
        }

        ShowGameOver();
    }

    static void ShowTitle()
    {
        Console.Clear();
        ColorWrite(@"
    ╔═══════════════════════════════════════╗
    ║                                       ║
    ║      ██████╗ ██╗   ██╗███╗   ██╗     ║
    ║      ██╔══██╗██║   ██║████╗  ██║     ║
    ║      ██║  ██║██║   ██║██╔██╗ ██║     ║
    ║      ██║  ██║██║   ██║██║╚██╗██║     ║
    ║      ██████╔╝╚██████╔╝██║ ╚████║     ║
    ║      ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝     ║
    ║                                       ║
    ║       D  U  N  G  E  O  N            ║
    ║                                       ║
    ╚═══════════════════════════════════════╝", ConsoleColor.DarkRed);

        ColorWrite("\n  Fight monsters, collect loot, survive!\n", ConsoleColor.Gray);
        ColorWrite("  Press any key to begin...\n", ConsoleColor.DarkGray);
        Console.ReadKey(true);
    }

    static void ExploreFloor()
    {
        Console.Clear();
        ShowStatus();
        Console.WriteLine();
        ColorWrite($"  ═══ Floor {player.Floor} ═══\n", ConsoleColor.Yellow);
        Console.WriteLine();
        ColorWrite("  You enter a dark corridor. Torch light flickers on the walls...\n", ConsoleColor.DarkGray);
        Thread.Sleep(800);

        int events = rng.Next(2, 5);
        for (int i = 0; i < events && !gameOver; i++)
        {
            int roll = rng.Next(100);
            if (roll < 50)
                MonsterEncounter();
            else if (roll < 75)
                TreasureRoom();
            else if (roll < 88)
                Shop();
            else
                Trap();

            if (!gameOver)
            {
                Console.WriteLine();
                ColorWrite("  Continue exploring? (Y/N): ", ConsoleColor.DarkGray);
                var key = Console.ReadKey(true).Key;
                if (key == ConsoleKey.N)
                {
                    gameOver = true;
                    return;
                }
            }
        }

        if (!gameOver)
        {
            Console.WriteLine();
            ColorWrite("  You found the stairs to the next floor!\n", ConsoleColor.Green);
            ColorWrite("  Descend? (Y/N): ", ConsoleColor.DarkGray);
            var key = Console.ReadKey(true).Key;
            if (key == ConsoleKey.Y)
            {
                player.Floor++;
                player.HP = Math.Min(player.HP + 20, player.MaxHP);
                ColorWrite("  You rest briefly and recover 20 HP.\n", ConsoleColor.Green);
                Thread.Sleep(1000);
            }
            else
            {
                gameOver = true;
            }
        }
    }

    static void MonsterEncounter()
    {
        Monster monster = GenerateMonster();
        ColorWrite($"\n  {monster.Icon} A {monster.Name} appears!\n", ConsoleColor.Red);
        Thread.Sleep(500);

        while (monster.HP > 0 && player.HP > 0 && !gameOver)
        {
            Console.WriteLine();
            ColorWrite($"  [{monster.Name}] HP: {HealthBar(monster.HP, monster.MaxHP)} {monster.HP}/{monster.MaxHP}", ConsoleColor.Red);
            Console.WriteLine();
            ColorWrite($"  [{player.Name}] HP: {HealthBar(player.HP, player.MaxHP)} {player.HP}/{player.MaxHP}", ConsoleColor.Green);
            Console.WriteLine();
            ColorWrite("\n  [A] Attack  [P] Potion  [R] Run\n", ConsoleColor.White);

            var key = Console.ReadKey(true).Key;
            if (key == ConsoleKey.A)
            {
                int dmg = Math.Max(0, player.TotalAttack - monster.Defense + rng.Next(-3, 4));
                int monsterDmg = Math.Max(0, monster.Attack - player.Defense + rng.Next(-2, 3));
                monster.HP -= dmg;
                player.HP -= monsterDmg;

                ColorWrite($"\n  You deal {dmg} damage to {monster.Name}!\n", ConsoleColor.Yellow);
                if (monsterDmg > 0)
                    ColorWrite($"  {monster.Name} hits you for {monsterDmg} damage!\n", ConsoleColor.DarkYellow);
                else
                    ColorWrite($"  {monster.Name} misses you!\n", ConsoleColor.DarkGray);
            }
            else if (key == ConsoleKey.P)
            {
                if (player.Potions > 0)
                {
                    int heal = rng.Next(25, 41);
                    player.HP = Math.Min(player.HP + heal, player.MaxHP);
                    player.Potions--;
                    ColorWrite($"\n  You drink a potion and restore {heal} HP!\n", ConsoleColor.Green);
                }
                else
                {
                    ColorWrite("\n  No potions left!\n", ConsoleColor.DarkGray);
                    continue;
                }

                int md = Math.Max(0, monster.Attack - player.Defense + rng.Next(-2, 3));
                player.HP -= md;
                if (md > 0)
                    ColorWrite($"  {monster.Name} hits you for {md} damage!\n", ConsoleColor.DarkYellow);
            }
            else if (key == ConsoleKey.R)
            {
                if (rng.Next(100) < 60)
                {
                    ColorWrite("\n  You successfully ran away!\n", ConsoleColor.Cyan);
                    return;
                }
                else
                {
                    int md = Math.Max(0, monster.Attack - player.Defense + rng.Next(0, 5));
                    player.HP -= md;
                    ColorWrite($"\n  Failed to run! {monster.Name} hits you for {md} damage!\n", ConsoleColor.DarkYellow);
                }
            }
        }

        if (player.HP <= 0)
        {
            gameOver = true;
            return;
        }

        if (monster.HP <= 0)
        {
            Console.WriteLine();
            ColorWrite(fightArts[rng.Next(fightArts.Length)], ConsoleColor.Red);
            Console.WriteLine();
            ColorWrite($"  You defeated {monster.Name}!\n", ConsoleColor.Green);
            ColorWrite($"  +{monster.GoldReward} gold\n", ConsoleColor.Yellow);
            player.Gold += monster.GoldReward;
            player.Kills++;

            if (rng.Next(100) < 35)
                DropLoot();
        }
    }

    static Monster GenerateMonster()
    {
        int floor = player.Floor;
        var templates = new List<(string name, string icon, int hp, int atk, int def, int gold)>
        {
            ("Rat",         "\U0001F400", 15 + floor * 3,  5 + floor,  1, 5 + floor * 2),
            ("Goblin",      "\U0001F47A", 25 + floor * 5,  8 + floor,  2, 10 + floor * 3),
            ("Skeleton",    "\U0001F480", 30 + floor * 5,  10 + floor * 2, 3, 12 + floor * 3),
            ("Orc",         "\U0001F479", 45 + floor * 7,  14 + floor * 2, 4, 18 + floor * 4),
            ("Dark Mage",   "\U0001F9D9", 35 + floor * 4,  18 + floor * 2, 2, 20 + floor * 5),
            ("Troll",       "\U0001F9CC", 60 + floor * 10, 16 + floor * 3, 6, 25 + floor * 5),
            ("Demon",       "\U0001F47F", 50 + floor * 8,  20 + floor * 3, 5, 30 + floor * 6),
            ("Dragon",      "\U0001F409", 80 + floor * 12, 22 + floor * 3, 7, 50 + floor * 8),
        };

        var (name, icon, hp, atk, def, gold) = templates[rng.Next(templates.Count)];
        return new Monster(name, icon, hp, atk, def, gold, 0);
    }

    static void TreasureRoom()
    {
        ColorWrite("\n  \U0001F4E6 You found a treasure chest!\n", ConsoleColor.Yellow);
        int roll = rng.Next(100);
        if (roll < 40)
        {
            int gold = rng.Next(10, 30) + player.Floor * 5;
            ColorWrite($"  Inside: {gold} gold coins!\n", ConsoleColor.Yellow);
            player.Gold += gold;
        }
        else if (roll < 70)
        {
            player.Potions += 1;
            ColorWrite("  Inside: A health potion!\n", ConsoleColor.Green);
        }
        else
        {
            int heal = rng.Next(15, 35);
            player.HP = Math.Min(player.HP + heal, player.MaxHP);
            ColorWrite($"  Inside: A mysterious elixir! Restores {heal} HP.\n", ConsoleColor.Magenta);
        }
    }

    static void Shop()
    {
        ColorWrite("\n  \U0001F3EA A wandering merchant appears!\n", ConsoleColor.Cyan);
        ColorWrite("  \"Traveler! Care to trade?\"\n\n", ConsoleColor.White);
        ColorWrite($"  [1] Health Potion (30 gold) - You have: {player.Potions}\n", ConsoleColor.Green);
        ColorWrite($"  [2] Upgrade Weapon (50 gold) - Current: {player.Weapon} (+{player.WeaponBonus})\n", ConsoleColor.Yellow);
        ColorWrite($"  [3] Armor Repair (40 gold) - +3 Defense permanently\n", ConsoleColor.Blue);
        ColorWrite("  [Q] Walk away\n", ConsoleColor.DarkGray);

        while (true)
        {
            var key = Console.ReadKey(true).Key;
            if (key == ConsoleKey.D1 || key == ConsoleKey.NumPad1)
            {
                if (player.Gold >= 30)
                {
                    player.Gold -= 30;
                    player.Potions++;
                    ColorWrite("  Purchased a health potion!\n", ConsoleColor.Green);
                }
                else
                    ColorWrite("  Not enough gold!\n", ConsoleColor.Red);
                break;
            }
            else if (key == ConsoleKey.D2 || key == ConsoleKey.NumPad2)
            {
                if (player.Gold >= 50)
                {
                    player.Gold -= 50;
                    player.WeaponBonus += 3;
                    var weapons = new[] { "Iron Sword", "Steel Blade", "Enchanted Axe", "Flame Sword", "Void Ripper" };
                    int idx = Math.Min(player.WeaponBonus / 3, weapons.Length - 1);
                    player.Weapon = weapons[idx];
                    ColorWrite($"  Weapon upgraded to {player.Weapon} (+{player.WeaponBonus})!\n", ConsoleColor.Yellow);
                }
                else
                    ColorWrite("  Not enough gold!\n", ConsoleColor.Red);
                break;
            }
            else if (key == ConsoleKey.D3 || key == ConsoleKey.NumPad3)
            {
                if (player.Gold >= 40)
                {
                    player.Gold -= 40;
                    player.Defense += 3;
                    ColorWrite($"  Armor reinforced! Defense: {player.Defense}\n", ConsoleColor.Blue);
                }
                else
                    ColorWrite("  Not enough gold!\n", ConsoleColor.Red);
                break;
            }
            else if (key == ConsoleKey.Q)
            {
                ColorWrite("  \"Maybe next time!\"\n", ConsoleColor.DarkGray);
                break;
            }
        }
    }

    static void Trap()
    {
        ColorWrite("\n  \u26A0\uFE0F You triggered a trap!\n", ConsoleColor.Red);
        int dmg = rng.Next(8, 20) + player.Floor * 2;
        player.HP -= dmg;
        ColorWrite($"  Took {dmg} damage!\n", ConsoleColor.DarkRed);
    }

    static void DropLoot()
    {
        var lootTable = new List<LootItem>
        {
            new("Health Potion", "+1 potion", 0),
            new("Gold Bag", "Bonus gold", rng.Next(10, 25)),
            new("Amulet of Power", "+2 Attack", 0),
            new("Iron Shield", "+2 Defense", 0),
        };

        var item = lootTable[rng.Next(lootTable.Count)];
        ColorWrite($"\n  \U0001F48E Loot dropped: {item.Name} - {item.Description}\n", ConsoleColor.Magenta);

        if (item.Name == "Health Potion")
            player.Potions++;
        else if (item.Name == "Gold Bag")
            player.Gold += item.Value;
        else if (item.Name == "Amulet of Power")
            player.Attack += 2;
        else if (item.Name == "Iron Shield")
            player.Defense += 2;
    }

    static string HealthBar(int current, int max)
    {
        int bars = 20;
        int filled = Math.Max(0, (int)((double)current / max * bars));
        return "[" + new string('|', filled) + new string('.', bars - filled) + "]";
    }

    static void ShowStatus()
    {
        ColorWrite("  ┌─────────────────────────────────────────────────────┐\n", ConsoleColor.DarkGray);
        ColorWrite($"  │ {player.Name}  ", ConsoleColor.White);
        ColorWrite($"HP: ", ConsoleColor.Gray);
        if (player.HP > player.MaxHP * 0.5)
            ColorWrite($"{player.HP}/{player.MaxHP} ", ConsoleColor.Green);
        else if (player.HP > player.MaxHP * 0.25)
            ColorWrite($"{player.HP}/{player.MaxHP} ", ConsoleColor.Yellow);
        else
            ColorWrite($"{player.HP}/{player.MaxHP} ", ConsoleColor.Red);
        ColorWrite($"ATK: {player.TotalAttack}  DEF: {player.Defense}  ", ConsoleColor.Gray);
        ColorWrite($"\U0001F4B0: {player.Gold}  ", ConsoleColor.Yellow);
        ColorWrite($"\U0001F48A: {player.Potions}  ", ConsoleColor.Green);
        ColorWrite($"Kills: {player.Kills}\n", ConsoleColor.DarkRed);
        ColorWrite($"  │ Weapon: {player.Weapon} (+{player.WeaponBonus})\n", ConsoleColor.Gray);
        ColorWrite("  └─────────────────────────────────────────────────────┘\n", ConsoleColor.DarkGray);
    }

    static void ShowGameOver()
    {
        Console.Clear();
        ColorWrite(@"
    ╔═══════════════════════════════╗
    ║                               ║
    ║       G A M E   O V E R       ║
    ║                               ║
    ╚═══════════════════════════════╝", ConsoleColor.Red);

        Console.WriteLine();
        ColorWrite($"  Adventurer: {player.Name}\n", ConsoleColor.White);
        ColorWrite($"  Floors explored: {player.Floor}\n", ConsoleColor.Yellow);
        ColorWrite($"  Monsters slain: {player.Kills}\n", ConsoleColor.DarkRed);
        ColorWrite($"  Gold collected: {player.Gold}\n", ConsoleColor.Yellow);
        Console.WriteLine();

        int score = player.Floor * 50 + player.Kills * 25 + player.Gold;
        ColorWrite($"  FINAL SCORE: {score}\n", ConsoleColor.Cyan);
        Console.WriteLine();
        ColorWrite("  Press any key to exit...\n", ConsoleColor.DarkGray);
        Console.ReadKey(true);
    }

    static void ColorWrite(string text, ConsoleColor color)
    {
        Console.ForegroundColor = color;
        Console.Write(text);
        Console.ResetColor();
    }
}
