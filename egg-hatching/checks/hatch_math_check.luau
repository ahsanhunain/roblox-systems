-- Run from the egg-hatching folder: lune run checks/hatch_math_check.luau
local M = require("../src/HatchMath")
local C = require("../src/HatchConfig")

local function near(a, b, tol)
	return math.abs(a - b) <= tol
end

local seed = 1
local rng = {
	NextNumber = function()
		seed = (seed * 1103515245 + 12345) % 2147483648
		return seed / 2147483648
	end,
}

local test = {
	Rarities = { "Common", "Rare", "Epic" },
	LuckAnchors = {
		{ luck = 0, odds = { Common = 80, Rare = 15, Epic = 5 } },
		{ luck = 100, odds = { Common = 20, Rare = 50, Epic = 30 } },
	},
	Pity = { { rarity = "Epic", hatches = 3 }, { rarity = "Rare", hatches = 2 } },
	StartLuck = 5,
	MaxLuck = 50,
}

local function odds(luck, pool)
	local t = {}
	for _, e in ipairs(M.rarityOdds(luck, test, pool)) do
		t[e.value] = e.weight
	end
	return t
end

assert(odds(0).Common == 80 and odds(0).Epic == 5, "anchor at luck 0")
assert(near(odds(50).Common, 50, 1e-9) and near(odds(50).Rare, 32.5, 1e-9), "blend at luck 50")
assert(odds(500).Epic == 30, "luck above last anchor clamps")
local noRare = odds(0, { Common = { 1 }, Epic = { 1 } })
assert(noRare.Rare == nil and near(noRare.Common, 80 / 85 * 100, 1e-9), "missing pool rarity is dropped and odds rescale")

assert(M.luck(test, 0) == 5 and M.luck(test, 100) == 50 and M.luck(test, -100) == 0, "luck clamp")

local counts, n = {}, 20000
for _ = 1, n do
	local r = M.rollRarity(0, test, nil, rng)
	counts[r] = (counts[r] or 0) + 1
end
assert(near(counts.Common / n * 100, 80, 1.5) and near(counts.Epic / n * 100, 5, 1), "roll distribution at luck 0")

local picks = {}
for _ = 1, n do
	local id = M.rollPet({ { id = "A", weight = 3 }, { id = "B", weight = 1 } }, rng)
	picks[id] = (picks[id] or 0) + 1
end
assert(near(picks.A / n, 0.75, 0.02), "pet weights")

local pity = {}
assert(M.tickPity(pity, test) == nil, "first hatch not due")
assert(M.tickPity(pity, test) == "Rare", "rare due after 2")
M.resetPity(pity, test, "Rare")
assert(pity.Rare == 2 and pity.Epic == 1, "rare resets rare only")
assert(M.tickPity(pity, test) == "Epic", "epic due after 3, beats rare")
M.resetPity(pity, test, "Epic")
assert(pity.Rare == 2 and pity.Epic == 3, "epic resets both")

for luck = C.StartLuck, C.MaxLuck do
	for name, egg in pairs(C.Eggs) do
		local sum = 0
		for _, e in ipairs(M.rarityOdds(luck, C, egg.pets)) do
			sum += e.weight
			assert(egg.pets[e.value], name .. " rolls " .. e.value .. " with no pets")
		end
		assert(near(sum, 100, 1e-6), name .. " odds sum at luck " .. luck)
	end
end

print("hatch math ok")
