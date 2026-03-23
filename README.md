# JaysServerLoot

Server-side additional zombie loot rolls for Project Zomboid Build 42 dedicated servers.

**Server-only mod.** Clients do not need this installed.

## What It Does

Adds configurable extra loot rolls to zombie corpses on top of vanilla loot. Never replaces or modifies existing drops — purely additive.

Default config adds era-appropriate items for 1993 Kentucky: cigarette packs, loose cigarettes, disposable lighters, and matches at historically realistic drop rates.

## Install

1. Place `JaysServerLoot` folder in your server's mods directory
2. Add `JaysServerLoot` to the `Mods=` line in your server `.ini`
3. Edit `config.lua` to customize items and chances
4. Restart the server

Clients do not need to subscribe or install anything.

## Configuration

Edit `Contents/mods/JaysServerLoot/42/media/lua/server/JaysServerLoot/config.lua`:

```lua
JaysServerLoot.ExtraRolls = 2
JaysServerLoot.Items = "Base.CigarettePack:0.25;Base.CigaretteSingle:0.15;Base.LighterDisposable:0.10;Base.Matches:0.08"
```

### Format

Items are defined as `Module.ItemID:chance` separated by semicolons.

- **Module.ItemID** — the full item ID (e.g. `Base.CigarettePack`)
- **chance** — drop chance per roll, 0.0 to 1.0 (0.25 = 25%)

### ExtraRolls

How many times the item table is rolled per zombie corpse. With `ExtraRolls = 2`, each item gets two independent chances to drop.

### Common Item IDs

| Item ID | Description |
|---------|-------------|
| Base.CigarettePack | Pack of cigarettes |
| Base.CigaretteSingle | Single cigarette |
| Base.CigaretteRolled | Hand-rolled cigarette |
| Base.Cigar | Cigar |
| Base.Cigarillo | Cigarillo |
| Base.CigaretteCarton | Carton of cigarettes |
| Base.LighterDisposable | Disposable lighter |
| Base.Lighter | Lighter |
| Base.Matches | Box of matches |
| Base.Wallet_Male | Wallet (male) |
| Base.Wallet_Female | Wallet (female) |
| Base.CreditCard | Credit card |
| Base.Money | Cash |
| Base.Coins | Coins |
| Base.Pills | Pills |
| Base.PillsAntiDep | Antidepressants |
| Base.PillsBeta | Beta blockers |

### Validation

On server start, every item ID is checked against PZ's item registry. Invalid items are logged and skipped — they won't crash the server.

```
[JaysServerLoot] Registered: Base.CigarettePack at 25.0% per roll
[JaysServerLoot] WARNING: Item 'Base.FakeItem' not found in game. Skipping.
[JaysServerLoot] Initialized with 4 item(s), 2 extra roll(s) per zombie
```

## How It Works

- `OnZombieDead` event fires on the server when a zombie dies
- The mod rolls the configured item table and adds won items to the corpse inventory
- Clients see the items when they loot the body — no client-side code needed
- All vanilla loot is untouched

## Compatibility

- Works alongside any other mod — no distribution table conflicts
- Does not modify vanilla loot tables
- Server-only — no client mod mismatch possible
