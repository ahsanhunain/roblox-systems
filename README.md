# Roblox systems by DOODLEWOOD Games

Production Luau systems written by Ahsan Hunain, founder of [DOODLEWOOD Games](https://doodlewoodgames.com/).
Each is taken from a shipped Roblox game and kept game agnostic, with every tunable value in one config module.

| System | What it does |
|---|---|
| [session-save](session-save/) | Player saves with session locking so two servers never write the same save, retries with backoff, autosave, safe shutdown and a Studio offline mode |
| [ragdoll-knockback](ragdoll-knockback/) | Server authoritative ragdoll with knockback that restores the character cleanly afterwards |
| [egg-hatching](egg-hatching/) | Server authoritative hatching with luck blended odds, pity, lucky hatches, weighted pets and a rate limited remote |
| [rebirth-economy](rebirth-economy/) | Coins, upgrades with stepped costs, selling and rebirths that reset progress for a multiplier, all checked on the server |

Shipped games: [Last Town Zombie Escape](https://www.roblox.com/games/85958529399721/UPD-LAST-TOWN-Zombie-Escape), [Find and Evolve Monsters](https://www.roblox.com/games/104146074760099/Find-Evolve-MONSTERS), [Octopus Energy Tycoon](https://www.roblox.com/games/114201343561910/Octopus-Energy-Tycoon).
