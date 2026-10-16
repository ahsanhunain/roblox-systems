# session-save

Player saves with session locking, retries, autosave, a safe shutdown and Studio offline mode.

| | |
|---|---|
| **Engine** | Roblox Luau |
| **Version** | 1.0 |
| **Came from** | a live Roblox game |
| **Used in** | a live Roblox game |
| **Status** | stable, live game |

## What it does

Loads one table per player from a DataStore, locks it to the current server so two servers never write it at once, fills in new template fields, autosaves, saves and releases on leave and on shutdown, and records `leftAt` for offline features. It does not do leaderstats, currencies or anything game specific: other services read and change the table through `DataService.Get(player)`.

## What it needs

Nothing.

## How to drop it in

1. Put `DataService`, `SessionStore` and `SaveConfig` in one folder in ServerScriptService.
2. Edit `SaveConfig.Template` with the game's save fields, and give `StoreName` a game-specific name.
3. Other services: `DataService.Loaded:Connect(function(player, data, isNew) ... end)` and `DataService.Get(player)`.
4. Call `DataService.Start()` **last**, after every other service has connected to `Loaded`.

## Config

| Setting | Default | What it does |
|---|---|---|
| `StoreName` / `StudioStoreName` | `Game_v1` / `Game_Studio_v1` | separate stores so Studio tests never touch live saves |
| `KeyPrefix` | `p_` | key is prefix + UserId |
| `AutosaveInterval` | `60` | seconds between autosaves |
| `LockTimeout` | `150` | a lock older than this is treated as dead |
| `LockWaitSeconds` / `LockRetryDelay` | `20` / `3` | how long to wait for another server to release |
| `Retries` / `RetryBaseDelay` | `5` / `1` | DataStore retries with doubling delay |
| `CloseWaitSeconds` | `25` | how long shutdown waits for saves |
| `StudioOfflineWithoutApi` | `true` | in Studio without API access, play with an unsaved template instead of kicking |
| `LoadedAttribute` | `DataLoaded` | player attribute set when the save is ready |
| `Template` | example | default save; new fields are added to old saves on load |

## Gotchas

- **`Loaded` is a plain listener list on purpose, not a BindableEvent.** A BindableEvent hands every listener a copy of the table, so changes made on load (offline time, rewards) silently vanish. This caused real bugs in a live game before the fix.
- Start `DataService` last, or early joiners load before other services are listening.
- `reconcile` only fills missing keys; renaming a field needs a migration.
- `DataService.Wipe(player, message)` kicks and saves a fresh template, for admin resets.

## Check it works

Enable Studio API access, play, change a value in `DataService.Get(player)`, stop, play again: the value is still there and `data.leftAt` is the stop time.

## Changelog

- **1.0** — first version, from a live game, including the fix for listeners receiving copies.
