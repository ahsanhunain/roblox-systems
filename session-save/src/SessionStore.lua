local SessionStore = {}

local function copy(value)
	if type(value) ~= "table" then
		return value
	end
	local out = {}
	for k, v in pairs(value) do
		out[k] = copy(v)
	end
	return out
end
SessionStore.copy = copy

function SessionStore.reconcile(data, template)
	for k, v in pairs(template) do
		if data[k] == nil then
			data[k] = copy(v)
		elseif type(v) == "table" and type(data[k]) == "table" and next(v) ~= nil then
			SessionStore.reconcile(data[k], v)
		end
	end
	return data
end

local function retry(config, fn)
	local lastError
	for attempt = 1, config.Retries do
		local ok, result = pcall(fn)
		if ok then
			return true, result
		end
		lastError = result
		if config.IsFatal and config.IsFatal(result) then
			break
		end
		if attempt < config.Retries then
			task.wait(config.RetryBaseDelay * 2 ^ (attempt - 1))
		end
	end
	return false, lastError
end

function SessionStore.load(store, key, sessionId, config, stillWanted)
	local deadline = os.clock() + config.LockWaitSeconds
	while true do
		local locked, isNew, loaded = false, false, nil
		local ok, err = retry(config, function()
			locked, isNew, loaded = false, false, nil
			store:UpdateAsync(key, function(old)
				if type(old) ~= "table" then
					old = {}
					isNew = true
				end
				local lock = old.lock
				if lock and lock.id ~= sessionId and os.time() - (lock.at or 0) < config.LockTimeout then
					locked = true
					return nil
				end
				old.lock = { id = sessionId, at = os.time() }
				loaded = old
				return old
			end)
		end)
		if not ok then
			return "error", err
		end
		if not locked then
			local data = copy(loaded)
			data.lock = nil
			return "ok", SessionStore.reconcile(data, config.Template), isNew
		end
		if os.clock() >= deadline or (stillWanted and not stillWanted()) then
			return "locked"
		end
		task.wait(config.LockRetryDelay)
	end
end

function SessionStore.save(store, key, sessionId, data, release, config, cancelled)
	local stolen = false
	local ok, err = retry(config, function()
		stolen = false
		store:UpdateAsync(key, function(old)
			if cancelled and cancelled() then
				return nil
			end
			if type(old) == "table" and old.lock and old.lock.id ~= sessionId then
				stolen = true
				return nil
			end
			local out = copy(data)
			out.lock = not release and { id = sessionId, at = os.time() } or nil
			return out
		end)
	end)
	if not ok then
		return "error", err
	end
	return stolen and "stolen" or "ok"
end

return SessionStore
