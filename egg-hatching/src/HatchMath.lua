-- Pure roll math. No Roblox services, so checks/hatch_math_check.luau can run it in Lune.
-- rng is anything with NextNumber() returning [0, 1), such as Random.new().

local HatchMath = {}

function HatchMath.pick(entries, rng)
	local total = 0
	for _, entry in ipairs(entries) do
		total += entry.weight
	end
	local r = rng:NextNumber() * total
	for _, entry in ipairs(entries) do
		r -= entry.weight
		if r < 0 then
			return entry.value
		end
	end
	return entries[#entries].value
end

function HatchMath.rank(rarities, name)
	return table.find(rarities, name) or 0
end

function HatchMath.luck(config, bonus)
	return math.clamp(config.StartLuck + (bonus or 0), 0, config.MaxLuck)
end

-- Odds move in a straight line between the two anchors around the current luck, then are
-- scaled to sum to 100. Rarities with no pets in this egg's pool are left out.
function HatchMath.rarityOdds(luck, config, pool)
	local anchors = config.LuckAnchors
	luck = math.clamp(luck, anchors[1].luck, anchors[#anchors].luck)
	local a, b = anchors[1], anchors[1]
	for i = 1, #anchors - 1 do
		if luck >= anchors[i].luck and luck <= anchors[i + 1].luck then
			a, b = anchors[i], anchors[i + 1]
			break
		end
	end
	local t = b.luck > a.luck and (luck - a.luck) / (b.luck - a.luck) or 0
	local list, total = {}, 0
	for _, rarity in ipairs(config.Rarities) do
		local from, to = a.odds[rarity], b.odds[rarity]
		if (from or to) and (not pool or (pool[rarity] and #pool[rarity] > 0)) then
			local w = (from or 0) + ((to or 0) - (from or 0)) * t
			if w > 0 then
				table.insert(list, { value = rarity, weight = w })
				total += w
			end
		end
	end
	for _, entry in ipairs(list) do
		entry.weight = entry.weight / total * 100
	end
	return list
end

function HatchMath.rollRarity(luck, config, pool, rng)
	return HatchMath.pick(HatchMath.rarityOdds(luck, config, pool), rng)
end

function HatchMath.rollPet(pets, rng)
	local entries = {}
	for _, pet in ipairs(pets) do
		table.insert(entries, { value = pet.id, weight = pet.weight })
	end
	return HatchMath.pick(entries, rng)
end

-- Counts every pity timer down by one and returns the first one that ran out. config.Pity is
-- listed highest rarity first, so the best due rarity wins.
function HatchMath.tickPity(pity, config)
	local due
	for _, entry in ipairs(config.Pity) do
		pity[entry.rarity] = (pity[entry.rarity] or entry.hatches) - 1
		if not due and pity[entry.rarity] <= 0 then
			due = entry.rarity
		end
	end
	return due
end

-- A hatch resets the timer of its own rarity and of every rarity below it.
function HatchMath.resetPity(pity, config, rolled)
	for _, entry in ipairs(config.Pity) do
		if HatchMath.rank(config.Rarities, rolled) >= HatchMath.rank(config.Rarities, entry.rarity) then
			pity[entry.rarity] = entry.hatches
		end
	end
end

return HatchMath
