-- Pure price math. No Roblox services, so checks/economy_math_check.luau can run it in Lune.

local EconomyMath = {}

function EconomyMath.isAmount(value)
	return type(value) == "number" and value == value and value >= 0 and value < math.huge
end

function EconomyMath.upgradeCost(upgrade, level)
	return upgrade.baseCost + upgrade.costStep * math.floor((level or 0) / upgrade.levelsPerStep)
end

function EconomyMath.rebirthPrice(config, index)
	local early = config.RebirthPrices
	if index <= #early then
		return early[index]
	end
	return config.RebirthAfterPrice + config.RebirthAfterStep * (index - #early - 1)
end

function EconomyMath.rebirthCost(config, done, amount)
	local total = 0
	for index = done + 1, done + amount do
		total += EconomyMath.rebirthPrice(config, index)
	end
	return total
end

function EconomyMath.multiplier(config, rebirths, levels)
	local mult = 1 + config.MultiplierPerRebirth * (rebirths or 0)
	for name, upgrade in pairs(config.Upgrades) do
		if upgrade.effect == "multiplier" then
			mult += upgrade.perLevel * ((levels and levels[name]) or 0)
		end
	end
	return mult
end

return EconomyMath
