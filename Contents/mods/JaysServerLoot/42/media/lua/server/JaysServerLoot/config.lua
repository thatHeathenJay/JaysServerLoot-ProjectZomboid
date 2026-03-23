JaysServerLoot = JaysServerLoot or {}

-- Modify zombie loot weights using "Module.ItemID:weight" separated by semicolons
-- Weight is relative to other items in the table (same scale as vanilla)
-- Higher weight = more common. For reference, vanilla values:
--   CigarettePack = 0.1, LighterDisposable = 0.5, Matches = 0.5
--   Wallet_Male = 50, IDcard_Male = 20, Comb = 1
--
-- If an item already exists in the table, its weight is overwritten.
-- If it doesn't exist, it's added.
--
-- Examples:
--   "Base.CigarettePack:2"                          (make packs 20x more common)
--   "Base.CigarettePack:2;Base.LighterDisposable:1" (multiple items)
--
-- Common item IDs:
--   Base.CigarettePack       Base.CigaretteSingle     Base.CigaretteRolled
--   Base.Cigar               Base.Cigarillo           Base.CigaretteCarton
--   Base.LighterDisposable   Base.Lighter             Base.Matches
--   Base.Wallet_Male         Base.Wallet_Female       Base.CreditCard
--   Base.Pills               Base.PillsAntiDep        Base.PillsBeta
--   Base.Coins               Base.Money
--
JaysServerLoot.Items = "Base.CigarettePack:2;Base.CigaretteSingle:1;Base.LighterDisposable:1;Base.Matches:0.8"
