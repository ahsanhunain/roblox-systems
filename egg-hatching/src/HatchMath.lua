-- HatchMath
-- Just the roll math, kept separate from the server code
-- (rng can be anything with NextNumber(), Random.new() is fine)

local HatchMath = {}

function HatchMath.pick(entries, rng)
	local total = 0
	for _, entry in ipairs(entries) do
		total += entry.weight
	end

	local roll = rng:NextNumber() * total
	for _, entry in ipairs(entries) do
		roll -= entry.weight
		if roll < 0 then
			return entry.value
		end
	end
	return entries[#entries].value -- float rounding
end

function HatchMath.rank(rarities, name)
	return table.find(rarities, name) or 0
end

function HatchMath.luck(config, bonus)
	return math.clamp(config.StartLuck + (bonus or 0), 0, config.MaxLuck)
end


-- Lerps between the two anchors around the luck value then scales back to 100.
-- Rarities with no pets in this egg get left out
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
			local weight = (from or 0) + ((to or 0) - (from or 0)) * t
			if weight > 0 then
				table.insert(list, { value = rarity, weight = weight })
				total += weight
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


-- Counts all the timers down by one and returns the best one that's due.
-- Works because config.Pity is sorted best first
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

-- Resets the timer for what you got and everything below it
function HatchMath.resetPity(pity, config, rolled)
	for _, entry in ipairs(config.Pity) do
		if HatchMath.rank(config.Rarities, rolled) >= HatchMath.rank(config.Rarities, entry.rarity) then
			pity[entry.rarity] = entry.hatches
		end
	end
end

return HatchMath
