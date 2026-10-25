# Game design (source of truth)

## Core feel
Fast, physical, weighty. Speed is power. Hitting things at speed is rewarded;
hitting walls at speed is a crash-stop with big feedback.

## Controls
| Input | Action |
|---|---|
| Mouse | Look |
| Left click held + mouse move | Slice at the crosshair (damage scales with swipe speed + player speed) |
| Right click | Use selected weapon (chains: fire / re-press to teleport to chain) |
| W A S D | Move |
| Space | Jump; Space mid-air = air jump (double jump) |
| Space x3 quickly mid-air | Slam: drops to ground very fast, shockwave knocks nearby players a few units away |
| F / Q / E / L-Alt | Dash forward / left / right / backward |
| 1 / 2 / 3 | Select hotbar weapon |

## Momentum
- Velocity is kept, not snapped. Low air friction.
- Attack damage = base * (1 + speed multiplier).
- Hitting a hard surface at high speed = **crash stop**: velocity zeroed, hitstop, shake, FOV snap, impact FX. Damage dealt to what you hit; chance of self-damage unless blocking.

## Inventory
3x2 grid = 6 slots. Player orders them. Slots 1-3 map to number keys.

## Weapons
1. **Gold chains** - harpoon launcher. Right click fires chain. Right click again while chain is in flight = teleport to the chain. Hitting a wall auto-teleports/pulls you there. Hitting an enemy: massive damage scaled by kinetic energy. Preserve velocity on arrival.
2. **Healer** - throwable. On impact creates a healing radius for a few seconds. Heals everyone inside, including you if thrown at your feet. Heavy to carry (slower walk while equipped).
3. **Pill** - 1.5 s use time. Stackable. Small instant heal + 5 s slow regen. For use away from enemies.
4. **Blocker** - hold to take zero damage from anything. If the shield is hit, it goes on a 10 s cooldown.

## Decisions
- First demo: **single-player vs bots only**. Multiplayer is later.
- Modding: external mods, a versioned mod API, and tester tools are part of development from the start.

## Open questions
- Is there a round/objective, or a bot-wave arena? (default: bot waves)
