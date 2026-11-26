local SaveConfig = {}

-- Change these for every game
SaveConfig.StoreName = "Game_v1"
SaveConfig.StudioStoreName = "Game_Studio_v1" -- so Studio testing never touches live saves
SaveConfig.KeyPrefix = "p_"
SaveConfig.Version = 1

-- Timings (seconds)
SaveConfig.AutosaveInterval = 60
SaveConfig.LockTimeout = 150 -- lock older than this = dead server
SaveConfig.LockWaitSeconds = 20
SaveConfig.LockRetryDelay = 3
SaveConfig.Retries = 5
SaveConfig.RetryBaseDelay = 1
SaveConfig.CloseWaitSeconds = 25

-- If API access is off in Studio, play with a blank save instead of getting kicked
SaveConfig.StudioOfflineWithoutApi = true
SaveConfig.StudioApiBlockedErrors = {
	"StudioAccessToApisNotAllowed",
	"Studio access to APIs is not allowed",
	"API access is not enabled",
}

SaveConfig.LoadFailMessage = "Your data could not be loaded. Please rejoin."
SaveConfig.LockedMessage = "Your data is still saving on another server. Please rejoin in a minute."

SaveConfig.LoadedAttribute = "DataLoaded"

-- Default save. New keys get added to old saves when they load
SaveConfig.Template = {
	cash = 0,
	leftAt = 0,
}

return SaveConfig
