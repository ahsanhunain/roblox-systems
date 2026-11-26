local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HatchConfig = require(script.Parent.HatchConfig)

local HatchClient = {}

local remote
local busy = false
local revealListeners = {}

-- Connect your egg animation to this
HatchClient.Revealed = {
	Connect = function(_, listener)
		table.insert(revealListeners, listener)
	end,
}

-- Returns the result, or nil + reason ("busy", "cooldown", "funds", "full", "invalid")
function HatchClient.Hatch(eggName)
	if busy then
		return nil, "busy"
	end

	busy = true
	local ok, result, reason = pcall(remote.InvokeServer, remote, eggName)
	busy = false

	if not ok then
		return nil, "invalid"
	end

	if result then
		for _, listener in ipairs(revealListeners) do
			task.spawn(listener, result)
		end
	end
	return result, reason
end

function HatchClient.Start()
	remote = ReplicatedStorage:WaitForChild(HatchConfig.RemoteName)
end

return HatchClient
