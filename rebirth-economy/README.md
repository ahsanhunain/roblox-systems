# rebirth-economy

Server authoritative coins, upgrades with rising costs, selling and rebirths that reset progress for a lasting multiplier.

| | |
|---|---|
| **Engine** | Roblox Luau |
| **Version** | 1.0 |
| **Came from** | a live Roblox game |
| **Used in** | a live Roblox game |
| **Status** | stable, price math checked in Lune |

## What it does

Keeps coins, rebirth points, rebirths and upgrade levels in the player's save. Income goes through `Earn`, which applies the rebirth and upgrade multiplier. Upgrades cost more every few levels and can be paid in coins or points. Rebirth costs coins on a rising price list, resets the fields you choose, and gives points and a bigger multiplier. Selling takes item uids from the client and asks the game for each price. The client only ever sends a rebirth amount, an upgrade name or a list of uids.

## What it needs

A save table per player. It pairs with [../session-save](../session-save/) (`getData = DataService.Get`). It adds these fields if missing: `coins`, `points`, `rebirths`, `upgrades`, `items`.

## How to drop it in

1. Put `EconomyConfig`, `EconomyMath`, `EconomyServer` and `EconomyClient` together in one folder in ReplicatedStorage.
2. Edit `EconomyConfig.Upgrades`, the rebirth prices and `ResetOnRebirth`.
3. Server: `EconomyServer.Start({ getData = DataService.Get, sellValue = function(player, item) return item.value end })` once. It makes RemoteFunctions `Rebirth`, `BuyUpgrade` and `Sell` in ReplicatedStorage.
4. Call `EconomyServer.Push(player)` once the save loads, so the attributes are set.
5. Game income: `EconomyServer.Earn(player, 10)`. Client: `EconomyClient.Start()`, then `EconomyClient.Rebirth(1)`, `EconomyClient.BuyUpgrade("CoinBoost")`, `EconomyClient.Sell({ uid1, uid2 })`.

Optional server hooks: `canSell(player)` returns false to refuse a sale, for example when the player is not at a sell spot; `onRebirth(player, data)` resets anything outside the save, such as placed objects. `sellValue` returning nil means that item cannot be sold, for example while it is equipped.

## Config

| Setting | Default | What it does |
|---|---|---|
| `Remotes` | Rebirth, BuyUpgrade, Sell | RemoteFunction names |
| `Cooldown` | `0.3` | seconds between calls per player per remote |
| `MaxPerSell` | `100` | most uids accepted in one sell |
| `CoinsField` / `PointsField` / `ItemsField` | `coins` / `points` / `items` | save field names |
| `Attributes` | Coins, Rebirths, Points, Multiplier | player attributes set for UI |
| `RebirthPrices` | `1000, 2500, 5000` | price of the first rebirths |
| `RebirthAfterPrice` / `RebirthAfterStep` | `10000` / `5000` | price after the list, rising by step each time |
| `RebirthAmounts` | `1, 3, 5` | how many rebirths one press may buy |
| `PointsPerRebirth` / `MultiplierPerRebirth` | `1` / `0.25` | what each rebirth gives |
| `ResetOnRebirth` | `{ coins = 0 }` | save fields set back on rebirth |
| `Upgrades` | 2 examples | `currency`, `max`, `baseCost`, `costStep`, `levelsPerStep`, optional `effect = "multiplier"` with `perLevel` |

## API

| Call | Returns |
|---|---|
| `EconomyServer.Earn(player, base)` | coins actually added, after the multiplier |
| `EconomyServer.AddCoins(player, amount)` / `SpendCoins(player, amount)` | true if done |
| `EconomyServer.GetCoins(player)` / `Multiplier(player)` | number |
| `EconomyServer.Rebirth(player, amount)` / `BuyUpgrade(player, name)` | true if done |
| `EconomyServer.Sell(player, uids)` | coins paid |
| `EconomyClient.RebirthCost(amount)` | price for UI, worked out again on the server |

An item in `items` needs a numeric `uid`. Anything else on it is for `sellValue`.

## Limits

- Only the `multiplier` effect is built in. Other upgrades, like `Speed` in the example, are read by the game from `data.upgrades[name]`.
- `ResetOnRebirth` copies table values one level deep.

## Check it works

`lune run checks/economy_math_check.luau` from this folder prints `economy math ok`. It checks rebirth prices before and after the list, bulk rebirth cost, stepped upgrade cost, the multiplier and amount validation.

## Changelog

- **1.0** — first version, from a live game. Per remote cooldowns added for publishing.
