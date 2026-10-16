local SaveConfig = {}

SaveConfig.StoreName = "Game_v1"
SaveConfig.StudioStoreName = "Game_Studio_v1"
SaveConfig.KeyPrefix = "p_"
SaveConfig.Version = 1

SaveConfig.AutosaveInterval = 60
SaveConfig.LockTimeout = 150
SaveConfig.LockWaitSeconds = 20
SaveConfig.LockRetryDelay = 3
SaveConfig.Retries = 5
SaveConfig.RetryBaseDelay = 1
SaveConfig.CloseWaitSeconds = 25
SaveConfig.StudioOfflineWithoutApi = true
SaveConfig.StudioApiBlockedErrors = { "StudioAccessToApisNotAllowed", "Studio access to APIs is not allowed", "API access is not enabled" }

SaveConfig.LoadFailMessage = "Your data could not be loaded. Please rejoin."
SaveConfig.LockedMessage = "Your data is still saving on another server. Please rejoin in a minute."

SaveConfig.LoadedAttribute = "DataLoaded"

SaveConfig.Template = {
	cash = 0,
	leftAt = 0,
}

return SaveConfig
