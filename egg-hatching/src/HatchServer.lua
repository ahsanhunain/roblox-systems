-- HatchServer
-- Ahsan Hunain
--
-- Client only sends the egg name. Price, rarity and pet are all decided here

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HatchConfig = require(script.Parent.HatchConfig)
local HatchMath = require(script.Parent.HatchMath)

local HatchServer = {}

local rng = Random.new()
local lastHatch = {}
local adapter


local function isAmount(value)
	-- value == value is false for NaN
	return type(value) == "number" and value == value and value >= 0 and value < math.huge
end

local function prepare(data)
	data[HatchConfig.CurrencyField] = data[HatchConfig.CurrencyField] or 0
	data[HatchConfig.PetsField] = data[HatchConfig.PetsField] or {}
	data.pity = data.pity or {}
	data.hatches = data.hatches or 0
	data.nextPetId = data.nextPetId or 1
end

local function luckOf(player, data, egg, lucky)
	local extra = adapter.getLuck and adapter.getLuck(player, data) or 0
	if not isAmount(extra) then
		extra = 0
	end

	local bonus = (egg.luckBonus or 0) + (lucky and HatchConfig.LuckyHatchBonus or 0) + extra
	return HatchMath.luck(HatchConfig, bonus)
end


function HatchServer.Hatch(player, eggName)
	local egg = type(eggName) == "string" and HatchConfig.Eggs[eggName] or nil
	local data = adapter.getData(player)
	if not egg or not data then
		return nil, "invalid"
	end

	local now = os.clock()
	local last = lastHatch[player.UserId]
	if last ~= nil and now - last < HatchConfig.Cooldown then
		return nil, "cooldown"
	end
	lastHatch[player.UserId] = now

	prepare(data)

	local pets = data[HatchConfig.PetsField]
	if #pets >= HatchConfig.MaxPets then
		return nil, "full"
	end
	if data[HatchConfig.CurrencyField] < egg.price then
		return nil, "funds"
	end
	data[HatchConfig.CurrencyField] -= egg.price

	data.hatches += 1
	local lucky = data.hatches % HatchConfig.LuckyHatchEvery == 0
	local luck = luckOf(player, data, egg, lucky)

	local due = HatchMath.tickPity(data.pity, HatchConfig)
	local rarity = HatchMath.rollRarity(luck, HatchConfig, egg.pets, rng)

	-- Pity bump. Skipped if this egg doesn't have that rarity, the timer just keeps going
	if due and egg.pets[due] and HatchMath.rank(HatchConfig.Rarities, rarity) < HatchMath.rank(HatchConfig.Rarities, due) then
		rarity = due
	end
	HatchMath.resetPity(data.pity, HatchConfig, rarity)

	local pet = {
		uid = data.nextPetId,
		id = HatchMath.rollPet(egg.pets[rarity], rng),
		rarity = rarity,
	}
	data.nextPetId += 1
	table.insert(pets, pet)

	if adapter.onHatched then
		task.spawn(adapter.onHatched, player, pet, data)
	end

	return { pet = pet, egg = eggName, lucky = lucky, luck = luck }
end

-- hooks.getData(player) is required
-- hooks.getLuck(player, data) and hooks.onHatched(player, pet, data) are optional
function HatchServer.Start(hooks)
	assert(hooks and hooks.getData, "HatchServer: missing getData")
	adapter = hooks

	local remote = ReplicatedStorage:FindFirstChild(HatchConfig.RemoteName) or Instance.new("RemoteFunction")
	remote.Name = HatchConfig.RemoteName
	remote.Parent = ReplicatedStorage
	remote.OnServerInvoke = HatchServer.Hatch

	Players.PlayerRemoving:Connect(function(player)
		lastHatch[player.UserId] = nil
	end)
end

return HatchServer
