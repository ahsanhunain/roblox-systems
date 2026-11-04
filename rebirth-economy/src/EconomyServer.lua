local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EconomyConfig = require(script.Parent.EconomyConfig)
local EconomyMath = require(script.Parent.EconomyMath)

local EconomyServer = {}

local COINS = EconomyConfig.CoinsField
local POINTS = EconomyConfig.PointsField
local ITEMS = EconomyConfig.ItemsField

local adapter
local lastCall = {}

local function getData(player)
	local data = adapter.getData(player)
	if data then
		data[COINS] = data[COINS] or 0
		data[POINTS] = data[POINTS] or 0
		data.rebirths = data.rebirths or 0
		data.upgrades = data.upgrades or {}
		data[ITEMS] = data[ITEMS] or {}
	end
	return data
end

function EconomyServer.Multiplier(player)
	local data = getData(player)
	return data and EconomyMath.multiplier(EconomyConfig, data.rebirths, data.upgrades) or 1
end

function EconomyServer.Push(player)
	local data = getData(player)
	if not data then
		return
	end
	local names = EconomyConfig.Attributes
	player:SetAttribute(names.Coins, data[COINS])
	player:SetAttribute(names.Rebirths, data.rebirths)
	player:SetAttribute(names.Points, data[POINTS])
	player:SetAttribute(names.Multiplier, EconomyMath.multiplier(EconomyConfig, data.rebirths, data.upgrades))
end

function EconomyServer.GetCoins(player)
	local data = getData(player)
	return data and data[COINS] or 0
end

function EconomyServer.AddCoins(player, amount)
	local data = getData(player)
	if not data or not EconomyMath.isAmount(amount) then
		return false
	end
	data[COINS] += amount
	EconomyServer.Push(player)
	return true
end

-- Game income goes through here so rebirths and multiplier upgrades apply.
function EconomyServer.Earn(player, baseAmount)
	if not EconomyMath.isAmount(baseAmount) then
		return 0
	end
	local amount = math.floor(baseAmount * EconomyServer.Multiplier(player))
	return EconomyServer.AddCoins(player, amount) and amount or 0
end

function EconomyServer.SpendCoins(player, amount)
	local data = getData(player)
	if not data or not EconomyMath.isAmount(amount) or data[COINS] < amount then
		return false
	end
	data[COINS] -= amount
	EconomyServer.Push(player)
	return true
end

function EconomyServer.Rebirth(player, amount)
	local data = getData(player)
	if not data or type(amount) ~= "number" or not table.find(EconomyConfig.RebirthAmounts, amount) then
		return false
	end
	local cost = EconomyMath.rebirthCost(EconomyConfig, data.rebirths, amount)
	if data[COINS] < cost then
		return false
	end
	-- Pay first, so rebirth is never free even if ResetOnRebirth does not reset coins.
	data[COINS] -= cost
	for field, value in pairs(EconomyConfig.ResetOnRebirth) do
		data[field] = type(value) == "table" and table.clone(value) or value
	end
	data.rebirths += amount
	data[POINTS] += amount * EconomyConfig.PointsPerRebirth
	if adapter.onRebirth then
		task.spawn(adapter.onRebirth, player, data)
	end
	EconomyServer.Push(player)
	return true
end

function EconomyServer.BuyUpgrade(player, name)
	local data = getData(player)
	local upgrade = type(name) == "string" and EconomyConfig.Upgrades[name] or nil
	if not data or not upgrade then
		return false
	end
	local level = data.upgrades[name] or 0
	if level >= upgrade.max then
		return false
	end
	local cost = EconomyMath.upgradeCost(upgrade, level)
	if (data[upgrade.currency] or 0) < cost then
		return false
	end
	data[upgrade.currency] -= cost
	data.upgrades[name] = level + 1
	EconomyServer.Push(player)
	return true
end

-- Sells the items whose uid is in ids. The price always comes from adapter.sellValue, never the client.
function EconomyServer.Sell(player, ids)
	local data = getData(player)
	if not data or not adapter.sellValue or type(ids) ~= "table" or #ids > EconomyConfig.MaxPerSell then
		return 0
	end
	if adapter.canSell and not adapter.canSell(player) then
		return 0
	end
	local wanted = {}
	for _, id in ipairs(ids) do
		if type(id) == "number" then
			wanted[id] = true
		end
	end
	local list, total, sold = data[ITEMS], 0, {}
	for index = #list, 1, -1 do
		local item = list[index]
		if wanted[item.uid] then
			local value = adapter.sellValue(player, item)
			if EconomyMath.isAmount(value) then
				total += value
				table.insert(sold, index)
			end
		end
	end
	-- Removed only after every price is known, so an erroring sellValue loses nothing.
	for _, index in ipairs(sold) do
		table.remove(list, index)
	end
	if total > 0 then
		EconomyServer.AddCoins(player, total)
	end
	return total
end

local function limited(action)
	return function(player, ...)
		local key = player.UserId .. action
		local now = os.clock()
		if lastCall[key] and now - lastCall[key] < EconomyConfig.Cooldown then
			return false
		end
		lastCall[key] = now
		return EconomyServer[action](player, ...)
	end
end

-- adapter.getData(player) -> save table or nil (required)
-- adapter.sellValue(player, item) -> coins, or nil if that item cannot be sold (needed for selling)
-- adapter.canSell(player) -> false to refuse, for example when away from a sell spot (optional)
-- adapter.onRebirth(player, data) to reset anything outside the save table (optional)
function EconomyServer.Start(hooks)
	assert(hooks and hooks.getData, "EconomyServer.Start needs { getData = function(player) }")
	adapter = hooks
	for action, remoteName in pairs(EconomyConfig.Remotes) do
		local remote = ReplicatedStorage:FindFirstChild(remoteName) or Instance.new("RemoteFunction")
		remote.Name = remoteName
		remote.Parent = ReplicatedStorage
		remote.OnServerInvoke = limited(action)
	end
	Players.PlayerRemoving:Connect(function(player)
		for action in pairs(EconomyConfig.Remotes) do
			lastCall[player.UserId .. action] = nil
		end
	end)
end

return EconomyServer
