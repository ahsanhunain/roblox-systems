# ragdoll-knockback

Knocks a player over into a smooth, floppy ragdoll with a push, then stands them back up.

| | |
|---|---|
| **Engine** | Roblox Luau |
| **Version** | 1.0 |
| **Came from** | a live Roblox game |
| **Used in** | a live Roblox game |
| **Status** | stable, tested with 2 players in Studio |

## What it does

`RagdollServer.Ragdoll(player, pushVelocity, seconds?)` makes the player's body go loose, throws it with the push, and gets them up after the time. It works on both old R15 rigs (Motor6D) and the new avatar joints (AnimationConstraint). It does not decide who gets hit; the caller (a bat, a trap, an explosion) does that.

## What it needs

Nothing. It makes its own RemoteEvent in ReplicatedStorage.

## How to drop it in

1. Put `RagdollConfig`, `RagdollServer` and `RagdollClient` together in one folder in ReplicatedStorage (the client needs `RagdollConfig` and `RagdollClient` too).
2. Server: `require(path.RagdollServer).Start()` once.
3. Client: `require(path.RagdollClient).Start()` once from a LocalScript.
4. To knock someone over: `RagdollServer.Ragdoll(player, direction * 45 + Vector3.new(0, 25, 0))`.

## Config

| Setting | Default | What it does |
|---|---|---|
| `Seconds` | `2.5` | time on the ground before getting up |
| `RemoteName` | `"Ragdoll"` | RemoteEvent name |
| `Attribute` | `"Ragdolled"` | character attribute while down, also blocks a second ragdoll |
| `CollisionGroup` | `"Ragdoll"` | group whose parts never hit each other |
| `HipsPart` | `"LowerTorso"` | the HumanoidRootPart is welded to this while down |
| `SocketAngle` / `SocketTwist` | `70` / `45` | joint looseness for old Motor6D rigs |
| `BlockedStates` | GettingUp, FallingDown, Ragdoll | states the client blocks while down |

## Gotchas

- **Never give the server network ownership of a player body** (`SetNetworkOwner(nil)`). Server physics runs slower and replicates choppy, and the body shakes on the ground.
- **Self-collision is what makes ragdolls shake at rest.** The collision group fixes it; NoCollisionConstraints on joints alone are not enough.
- **New avatar joints have no Motor6Ds.** Each joint is an AnimationConstraint plus an already-enabled BallSocketConstraint, so disabling the AnimationConstraints is all it takes. A Motor6D-only ragdoll leaves these avatars stiff.
- The Humanoid state must be set to Physics on the **owning client**; setting it on the server does nothing for a player.
- The push is set on every body part, not only the HumanoidRootPart, or the loose limbs drag it to a stop after a few studs.

## Check it works

In Play, from the Server: `RagdollServer.Ragdoll(player, player.Character.HumanoidRootPart.CFrame.RightVector * 45 + Vector3.new(0, 25, 0))`. On the client, sum the AssemblyLinearVelocity of all body parts: the player flies about 28 studs, lands within about 1.3 s, the total speed reads 0.0 while lying, and they stand up after `Seconds`.

## Changelog

- **1.0** — first version, from a live game. Built after DevForum research on smooth player ragdolls.
