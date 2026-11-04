# egg-hatching

Server authoritative egg hatching: pay, roll a rarity with luck and pity, roll a pet, add it to the save.

| | |
|---|---|
| **Engine** | Roblox Luau |
| **Version** | 1.0 |
| **Came from** | a live Roblox game |
| **Used in** | a live Roblox game |
| **Status** | stable, roll math checked in Lune |

## What it does

The client asks to hatch an egg by name. The server checks the name, the cooldown, pet space and coins, takes the price, rolls a rarity from luck blended between anchor points, applies pity, picks a weighted pet of that rarity and adds it to the player's save. Every 10th hatch is a lucky hatch with bonus luck. The client never sends a price, a rarity or a pet. It does not draw anything: the reveal is a hook for the game's own effect.

## What it needs

A save table per player. It pairs with [../session-save](../session-save/) (`getData = DataService.Get`), but any function that returns a table works. It adds these fields if missing: `coins`, `pets`, `pity`, `hatches`, `nextPetId`.

## How to drop it in

1. Put `HatchConfig`, `HatchMath`, `HatchServer` and `HatchClient` together in one folder in ReplicatedStorage.
2. Edit `HatchConfig.Eggs` with the game's eggs and pet ids.
3. Server: `HatchServer.Start({ getData = DataService.Get })` once. It makes a RemoteFunction named `Hatch` in ReplicatedStorage.
4. Client: `HatchClient.Start()` once, then `HatchClient.Hatch("Basic")` from a button. Show the pet in `HatchClient.Revealed:Connect(function(result) ... end)`.

Optional server hooks: `getLuck(player, data)` returns extra luck from upgrades or boosts; `onHatched(player, pet, data)` runs after the pet is added, for leaderstats or spawning the pet.

## Config

| Setting | Default | What it does |
|---|---|---|
| `RemoteName` | `"Hatch"` | RemoteFunction name |
| `Cooldown` | `0.5` | seconds between hatches per player, enforced on the server |
| `CurrencyField` / `PetsField` | `coins` / `pets` | save fields for money and the pet list |
| `MaxPets` | `200` | hatching stops when the pet list is this long |
| `StartLuck` / `MaxLuck` | `0` / `100` | luck range; luck is clamped into it |
| `LuckyHatchEvery` / `LuckyHatchBonus` | `10` / `10` | every Nth hatch gets this much extra luck |
| `Rarities` | Common to Legendary | rarity order, lowest first |
| `LuckAnchors` | 3 example anchors | rarity odds at set luck values, blended in between |
| `Pity` | Legendary 100, Epic 25 | highest first; guarantees a rarity after that many hatches without it |
| `Eggs` | 2 examples | `price`, optional `luckBonus`, and `pets` per rarity as `{ id, weight }` |

## API

| Call | Side | Returns |
|---|---|---|
| `HatchServer.Hatch(player, eggName)` | server | `{ pet, egg, lucky, luck }` or `nil, reason` |
| `HatchClient.Hatch(eggName)` | client | same as above, reasons `busy`, `cooldown`, `funds`, `full`, `invalid` |
| `HatchMath.rarityOdds(luck, config, pool)` | both | list of `{ value = rarity, weight = percent }`, for an odds display |

A pet in the save is `{ uid, id, rarity }`. `uid` is unique per player.

## Limits

- Pity is shared across all eggs. An egg that has no pets of the due rarity skips the pity bump and keeps the timer.
- A rarity with no pets in an egg is left out of that egg's odds and the rest are rescaled.
- One hatch per call. Multi hatch is a loop on the client, still held to `Cooldown`.

## Check it works

`lune run checks/hatch_math_check.luau` from this folder prints `hatch math ok`. It checks the blended odds, the rescale, a 20000 roll distribution, pet weights, pity timing and that every shipped egg's odds sum to 100.

## Changelog

- **1.0** — first version, from a live game.
