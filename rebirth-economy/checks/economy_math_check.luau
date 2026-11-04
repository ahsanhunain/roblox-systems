-- Run from the rebirth-economy folder: lune run checks/economy_math_check.luau
local M = require("../src/EconomyMath")
local C = require("../src/EconomyConfig")

local test = {
	RebirthPrices = { 100, 200 },
	RebirthAfterPrice = 1000,
	RebirthAfterStep = 50,
	MultiplierPerRebirth = 0.5,
	Upgrades = {
		Boost = { effect = "multiplier", perLevel = 0.1 },
		Other = {},
	},
}

local want = { 100, 200, 1000, 1050, 1100 }
for i, v in ipairs(want) do
	assert(M.rebirthPrice(test, i) == v, `rebirth {i}: got {M.rebirthPrice(test, i)} want {v}`)
end
assert(M.rebirthCost(test, 0, 1) == 100, "first rebirth")
assert(M.rebirthCost(test, 0, 3) == 1300, "three from zero")
assert(M.rebirthCost(test, 2, 2) == 2050, "two from two")

local stepped = { baseCost = 10, costStep = 5, levelsPerStep = 2 }
assert(M.upgradeCost(stepped, 0) == 10 and M.upgradeCost(stepped, 1) == 10, "same price inside a step")
assert(M.upgradeCost(stepped, 2) == 15 and M.upgradeCost(stepped, 5) == 20, "price rises each step")

assert(M.multiplier(test, 0, {}) == 1, "base multiplier")
assert(math.abs(M.multiplier(test, 2, { Boost = 3, Other = 9 }) - 2.3) < 1e-9, "rebirths plus boost, other ignored")

assert(M.isAmount(5) and M.isAmount(0), "plain amounts")
assert(not M.isAmount(-1) and not M.isAmount(0 / 0) and not M.isAmount(math.huge) and not M.isAmount("5"), "bad amounts refused")

for name, upgrade in pairs(C.Upgrades) do
	assert(upgrade.currency and upgrade.max and upgrade.levelsPerStep > 0, name .. " config")
end
for i = 1, 50 do
	assert(M.rebirthPrice(C, i + 1) >= M.rebirthPrice(C, i), "shipped rebirth prices never drop")
end

print("economy math ok")
