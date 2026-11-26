local EconomyConfig = {}

EconomyConfig.Remotes = { Rebirth = "Rebirth", BuyUpgrade = "BuyUpgrade", Sell = "Sell" }
EconomyConfig.Cooldown = 0.3
EconomyConfig.MaxPerSell = 100

EconomyConfig.CoinsField = "coins"
EconomyConfig.PointsField = "points"
EconomyConfig.ItemsField = "items"

-- Server keeps these updated for the UI, client only reads them
EconomyConfig.Attributes = { Coins = "Coins", Rebirths = "Rebirths", Points = "Points", Multiplier = "Multiplier" }

-- First ones use the list, after that it's AfterPrice + AfterStep for each one
EconomyConfig.RebirthPrices = { 1000, 2500, 5000 }
EconomyConfig.RebirthAfterPrice = 10000
EconomyConfig.RebirthAfterStep = 5000
EconomyConfig.RebirthAmounts = { 1, 3, 5 }
EconomyConfig.PointsPerRebirth = 1
EconomyConfig.MultiplierPerRebirth = 0.25

-- Fields that get reset on rebirth (tables are cloned)
EconomyConfig.ResetOnRebirth = { coins = 0 }

-- cost = baseCost + costStep * floor(level / levelsPerStep)
-- effect = "multiplier" adds perLevel to the coin multiplier for each level
EconomyConfig.Upgrades = {
	CoinBoost = { currency = "points", max = 20, baseCost = 1, costStep = 2, levelsPerStep = 1, effect = "multiplier", perLevel = 0.1 },
	Speed = { currency = "coins", max = 10, baseCost = 500, costStep = 500, levelsPerStep = 2 },
}

return EconomyConfig
