local HatchConfig = {}

HatchConfig.RemoteName = "Hatch"
HatchConfig.Cooldown = 0.5

HatchConfig.CurrencyField = "coins"
HatchConfig.PetsField = "pets"
HatchConfig.MaxPets = 200

HatchConfig.StartLuck = 0
HatchConfig.MaxLuck = 100
HatchConfig.LuckyHatchEvery = 10
HatchConfig.LuckyHatchBonus = 10

-- Worst to best. Order matters, pity uses it
HatchConfig.Rarities = { "Common", "Rare", "Epic", "Legendary" }

-- Odds (%) at each luck value. Anything in between gets blended
HatchConfig.LuckAnchors = {
	{ luck = 0, odds = { Common = 70, Rare = 22, Epic = 7, Legendary = 1 } },
	{ luck = 50, odds = { Common = 40, Rare = 35, Epic = 20, Legendary = 5 } },
	{ luck = 100, odds = { Common = 10, Rare = 40, Epic = 35, Legendary = 15 } },
}

-- Best first! Guaranteed after this many hatches without one
HatchConfig.Pity = {
	{ rarity = "Legendary", hatches = 100 },
	{ rarity = "Epic", hatches = 25 },
}

-- Example eggs, swap the ids for your own pets
HatchConfig.Eggs = {
	Basic = {
		price = 100,
		pets = {
			Common = { { id = "PetA", weight = 60 }, { id = "PetB", weight = 40 } },
			Rare = { { id = "PetC", weight = 1 } },
			Epic = { { id = "PetD", weight = 1 } },
			Legendary = { { id = "PetE", weight = 1 } },
		},
	},
	Golden = {
		price = 1000,
		luckBonus = 20,
		pets = {
			Rare = { { id = "PetF", weight = 70 }, { id = "PetG", weight = 30 } },
			Epic = { { id = "PetH", weight = 1 } },
			Legendary = { { id = "PetI", weight = 1 } },
		},
	},
}

return HatchConfig
