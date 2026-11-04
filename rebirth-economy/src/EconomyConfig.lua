local EconomyConfig = {}

EconomyConfig.Remotes = { Rebirth = "Rebirth", BuyUpgrade = "BuyUpgrade", Sell = "Sell" }
EconomyConfig.Cooldown = 0.3
EconomyConfig.MaxPerSell = 100
EconomyConfig.CoinsField = "coins"
EconomyConfig.PointsField = "points"
EconomyConfig.ItemsField = "items"

-- Player attributes the server keeps up to date for UI. Clients read, never write.
EconomyConfig.Attributes = { Coins = "Coins", Rebirths = "Rebirths", Points = "Points", Multiplier = "Multiplier" }

-- Rebirth price for the Nth rebirth: the list first, then After plus Step for each one past it.
EconomyConfig.RebirthPrices = { 1000, 2500, 5000 }
EconomyConfig.RebirthAfterPrice = 10000
EconomyConfig.RebirthAfterStep = 5000
EconomyConfig.RebirthAmounts = { 1, 3, 5 }
EconomyConfig.PointsPerRebirth = 1
EconomyConfig.MultiplierPerRebirth = 0.25

-- Save fields set back to these values on rebirth. A table value is cloned, so saves never share it.
EconomyConfig.ResetOnRebirth = { coins = 0 }

-- Cost of the next level = baseCost + costStep * floor(level / levelsPerStep), paid in the
-- save field named by currency. effect "multiplier" adds perLevel per level to coin earnings.
EconomyConfig.Upgrades = {
	CoinBoost = { currency = "points", max = 20, baseCost = 1, costStep = 2, levelsPerStep = 1, effect = "multiplier", perLevel = 0.1 },
	Speed = { currency = "coins", max = 10, baseCost = 500, costStep = 500, levelsPerStep = 2 },
}

return EconomyConfig
