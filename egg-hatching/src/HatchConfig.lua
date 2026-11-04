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

-- Lowest to highest. Rank in this list decides pity and "better than".
HatchConfig.Rarities = { "Common", "Rare", "Epic", "Legendary" }

-- Odds in percent at a given luck. Luck between two anchors blends them.
HatchConfig.LuckAnchors = {
	{ luck = 0, odds = { Common = 70, Rare = 22, Epic = 7, Legendary = 1 } },
	{ luck = 50, odds = { Common = 40, Rare = 35, Epic = 20, Legendary = 5 } },
	{ luck = 100, odds = { Common = 10, Rare = 40, Epic = 35, Legendary = 15 } },
}

-- Highest rarity first. After this many hatches without one, the next hatch is at least that rarity.
HatchConfig.Pity = {
	{ rarity = "Legendary", hatches = 100 },
	{ rarity = "Epic", hatches = 25 },
}

-- Example eggs. Pet ids are whatever the game uses to find its pet models.
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
