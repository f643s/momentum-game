# Roadmap (one phase at a time)

Scope of the first demo: **single-player vs bots. No multiplayer.**
Each phase has an **Acceptance** list. Do not move on until all boxes are true.

## Phase 0 - Project and blank room
- Project, git repo, `world.tscn` with floor, light, sky.
- **Acceptance:** [ ] Runs with F5  [ ] Committed

## Phase 1 - Basic player + config resource
- `player.tscn`, mouse look, WASD, jump, gravity. Tuning values live in `MovementConfig` (a Resource), not hard-coded.
- **Acceptance:** [ ] Look/walk/jump  [ ] Changing a value in the config changes the feel without editing code

## Phase 2 - Momentum movement
- Ground/air acceleration, low air friction, speed-based FOV.
- **Acceptance:** [ ] Slidey but controllable  [ ] Speed readout

## Phase 2.5 - Dev console and debug overlay (tester tools v1)
- `DevConsole` autoload with `god`, `noclip`, `timescale`, `tp`, `set`; F1 stats overlay.
- **Acceptance:** [ ] `` ` `` opens console  [ ] `timescale 0.2` slows the game  [ ] F1 shows speed and state

## Phase 3 - Air jump, dashes, slam
- Air jump, 4 dashes with cooldowns, triple-space slam + shockwave.
- **Acceptance:** [ ] Air jump  [ ] 4 dashes  [ ] Slam pushes a dummy

## Phase 4 - Health, damage, and bots v1
- `Health` component. `BotDef` Resource. Bot scene that chases the player and has knockback. `spawn_bot` console command.
- **Acceptance:** [ ] Bots chase, take damage, die  [ ] Console spawns them

## Phase 5 - Crash stop
- **Acceptance:** [ ] Full-speed wall hit = stop + hitstop + shake  [ ] Light taps do nothing  [ ] `speed_run.tscn` test room exists

## Phase 6 - Slicing
- **Acceptance:** [ ] Fast swipes hurt, slow ones do not  [ ] Running + slicing hurts more  [ ] F4 shows damage numbers

## Phase 7 - Weapons (as WeaponDef resources + registry)
- Order: blocker, pill, healer, gold chains. Hotbar 1-3, simple HUD.
- **Acceptance:** per weapon in `docs/06-testing.md`; each weapon is registered by id (`base:blocker`, etc.)

## Phase 8 - Inventory
- 3x2 grid UI, drag to reorder, hotbar mirrors first three slots.

## Phase 9 - Bot AI v2 + arena
- Bot behaviours (rusher, kiter, blocker-user), waves in `bot_arena.tscn`, F3 AI debug overlay.
- **Acceptance:** [ ] 3 distinct bot types  [ ] Waves spawn and end

## Phase M1-M5 - Modding (see `docs/07-modding.md`)
- Slot these in once Phase 7 is done, because weapons and bots must exist as data first.
- **Acceptance:** [ ] Example mod `.pck` in `user://mods/` adds a new weapon that appears in game

## Phase 10 - Juice pass (`docs/05-juice.md`)

## Phase 11 - Demo packaging
- Export presets for Linux, a main menu, a bot-arena demo level, tester build with tools enabled and a release build with them stripped.

## Later (not in first demo)
- Multiplayer
