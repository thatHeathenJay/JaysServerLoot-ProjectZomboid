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
- Safe to add or remove at any time

## Changelog

### v1.5 — Sync Fix v2
- Separated AddItem (always immediate) from sendAddItemToContainer (pcall-wrapped)
- Items now exist server-side immediately, sync notification retried separately
- Failed syncs queued and retried each tick up to 60 times
- PZ naturally resyncs container contents when player opens corpse as fallback
- No more server log errors from grid square null state

### v1.4 — Default Config Tuning
- Changed default ExtraRolls from 2 to 1 (prevents duplicate items per zombie)
- Changed default CigarettePack chance from 25% to 20%
- More realistic era-appropriate loot distribution

### v1.3 — Deferred Loot Sync
- Fixed phantom items that couldn't be grabbed by players
- Root cause: sendAddItemToContainer fails when zombie's grid square is null during OnZombieDead
- Items now check for valid grid square before syncing to clients
- If square isn't ready, loot is deferred to a pending queue and retried each tick (up to 30 attempts)
- Loot rolls are determined immediately so timing doesn't affect drop results

### v1.2 — Drainable Item Fix
- Fixed drainable items (CigarettePack, LighterDisposable, etc.) spawning empty/unusable
- Drainable items now spawn 20-100% full for realism (partially used packs)
- Non-drainable items unaffected
- Fixed initialization: use OnInitGlobalModData instead of OnGameStart (OnGameStart does not fire on dedicated servers)

### v1.1 — Hardened
- Wrapped all Java boundary calls in pcall (zombie:getInventory, ScriptManager, body:AddItem)
- Wrapped onGameStart initialization in pcall with fallback
- Mod cannot crash the server under any circumstance

### v1.0 — Initial Release
- Configurable extra loot rolls on zombie death
- Semicolon-separated item:chance config format
- Item validation against PZ's item registry on startup
- Purely additive — never replaces vanilla loot
- Server-only — no client install required
