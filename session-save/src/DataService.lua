-- DataService
-- Ahsan Hunain

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local SaveConfig = require(script.Parent.SaveConfig)
local SessionStore = require(script.Parent.SessionStore)

local DataService = {}

local sessionId = game.JobId ~= "" and game.JobId or HttpService:GenerateGUID(false)
local store
local offline = false
local profiles = {}
local inFlight, loading = 0, 0
local busy = {}
local wipes = {}

-- Not a BindableEvent on purpose. Those pass a copy of the table so anything
-- you change on load just disappears (got burned by this in a live game)
local listeners = {}
DataService.Loaded = {
	Connect = function(_, fn)
		table.insert(listeners, fn)
	end,
}


local function keyOf(userId)
	return SaveConfig.KeyPrefix .. userId
end

-- Studio with API access off, no point retrying
local function isApiBlocked(err)
	if not RunService:IsStudio() then
		return false
	end

	for _, msg in ipairs(SaveConfig.StudioApiBlockedErrors) do
		if tostring(err):find(msg, 1, true) then
			return true
		end
	end
	return false
end

local config = setmetatable({ IsFatal = isApiBlocked }, { __index = SaveConfig })


function DataService.Get(player)
	local profile = profiles[player.UserId]
	return profile and profile.data or nil
end

function DataService.IsLoaded(player)
	return profiles[player.UserId] ~= nil
end


local function finishLoad(player, data, isNew)
	if player.Parent == nil then
		return false -- left while loading
	end

	data.v = SaveConfig.Version
	profiles[player.UserId] = { data = data, released = false }
	player:SetAttribute(SaveConfig.LoadedAttribute, true)

	for _, fn in ipairs(listeners) do
		task.spawn(fn, player, data, isNew)
	end
	return true
end

local function tryLoad(player)
	if offline then
		finishLoad(player, SessionStore.reconcile({}, SaveConfig.Template), true)
		return
	end

	local status, data, isNew = SessionStore.load(store, keyOf(player.UserId), sessionId, config, function()
		return player.Parent ~= nil
	end)

	if status == "error" and SaveConfig.StudioOfflineWithoutApi and isApiBlocked(data) then
		offline = true
		finishLoad(player, SessionStore.reconcile({}, SaveConfig.Template), true)
		return
	end

	if status == "ok" then
		if not finishLoad(player, data, isNew) then
			-- They left, give the lock back
			SessionStore.save(store, keyOf(player.UserId), sessionId, data, true, config)
		end
	elseif player.Parent then
		player:Kick(status == "locked" and SaveConfig.LockedMessage or SaveConfig.LoadFailMessage)
	end
end

local function loadPlayer(player)
	local id = player.UserId
	if profiles[id] or busy[id] then
		return
	end

	busy[id] = true
	loading += 1
	local ok, err = pcall(tryLoad, player)
	loading -= 1
	busy[id] = nil

	if not ok then
		if player.Parent and not profiles[id] then
			player:Kick(SaveConfig.LoadFailMessage)
		end
		error(err, 0)
	end
end

-- For admin resets. Kicks them and the leave save writes a fresh template
function DataService.Wipe(player, msg)
	wipes[player.UserId] = true
	player:Kick(msg)
end

local function savePlayer(userId, release)
	local profile = profiles[userId]
	if not profile or offline then
		return
	end

	local data = profile.data
	if release and wipes[userId] then
		wipes[userId] = nil
		data = SessionStore.reconcile({}, SaveConfig.Template)
	end
	if release then
		profile.released = true
		profiles[userId] = nil
	end

	inFlight += 1
	SessionStore.save(store, keyOf(userId), sessionId, data, release, config, function()
		-- autosave finished after they left, dont put the lock back on
		return not release and profile.released
	end)
	inFlight -= 1
end

function DataService.Save(player)
	savePlayer(player.UserId, false)
end


-- Call this LAST, after every other service is connected to Loaded
function DataService.Start()
	store = DataStoreService:GetDataStore(RunService:IsStudio() and SaveConfig.StudioStoreName or SaveConfig.StoreName)

	Players.PlayerAdded:Connect(loadPlayer)
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(loadPlayer, player)
	end

	Players.PlayerRemoving:Connect(function(player)
		local profile = profiles[player.UserId]
		if profile ~= nil then
			profile.data.leftAt = os.time()
		end
		busy[player.UserId] = nil
		savePlayer(player.UserId, true)
	end)

	task.spawn(function()
		while true do
			task.wait(SaveConfig.AutosaveInterval)
			for _, player in ipairs(Players:GetPlayers()) do
				task.spawn(savePlayer, player.UserId, false)
			end
		end
	end)

	game:BindToClose(function()
		for userId, profile in pairs(profiles) do
			profile.data.leftAt = os.time()
			task.spawn(savePlayer, userId, true)
		end

		local deadline = os.clock() + SaveConfig.CloseWaitSeconds
		while (inFlight > 0 or loading > 0) and os.clock() < deadline do
			task.wait(0.1)
		end
	end)
end

return DataService
