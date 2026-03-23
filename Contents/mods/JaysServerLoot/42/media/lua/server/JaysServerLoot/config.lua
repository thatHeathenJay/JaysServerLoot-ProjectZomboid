JaysServerLoot = JaysServerLoot or {}

-- How many extra rolls per zombie corpse (on top of vanilla loot)
JaysServerLoot.ExtraRolls = 1

-- Define additional zombie loot as "Module.ItemID:chance" separated by semicolons
-- Chance is 0.0 to 1.0 (e.g. 0.25 = 25% chance per roll)
-- These are ADDED to vanilla loot, never replacing it
--
-- Examples:
--   "Base.CigarettePack:0.25"                     (single item)
--   "Base.CigarettePack:0.25;Base.Matches:0.10"   (multiple items)
--
-- Common item IDs:
--   Base.CigarettePack       Base.CigaretteSingle     Base.CigaretteRolled
--   Base.Cigar               Base.Cigarillo           Base.CigaretteCarton
--   Base.LighterDisposable   Base.Lighter             Base.Matches
--   Base.Wallet_Male         Base.Wallet_Female       Base.CreditCard
--   Base.Pills               Base.PillsAntiDep        Base.PillsBeta
--   Base.Coins               Base.Money
--
JaysServerLoot.Items = "Base.CigarettePack:0.20;Base.CigaretteSingle:0.15;Base.LighterDisposable:0.10;Base.Matches:0.08"
