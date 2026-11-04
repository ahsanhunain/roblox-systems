local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EconomyConfig = require(script.Parent.EconomyConfig)
local EconomyMath = require(script.Parent.EconomyMath)

local player = Players.LocalPlayer

local EconomyClient = {}

local remotes = {}

local function invoke(action, ...)
	local ok, result = pcall(remotes[action].InvokeServer, remotes[action], ...)
	return ok and result
end

function EconomyClient.Rebirth(amount)
	return invoke("Rebirth", amount)
end

function EconomyClient.BuyUpgrade(name)
	return invoke("BuyUpgrade", name)
end

function EconomyClient.Sell(ids)
	return invoke("Sell", ids)
end

-- For UI only. The server works the real price out again.
function EconomyClient.RebirthCost(amount)
	return EconomyMath.rebirthCost(EconomyConfig, player:GetAttribute(EconomyConfig.Attributes.Rebirths) or 0, amount)
end

function EconomyClient.Get(attribute)
	return player:GetAttribute(EconomyConfig.Attributes[attribute])
end

function EconomyClient.Start()
	for action, remoteName in pairs(EconomyConfig.Remotes) do
		remotes[action] = ReplicatedStorage:WaitForChild(remoteName)
	end
end

return EconomyClient
