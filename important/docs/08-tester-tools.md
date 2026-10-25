# Tester's tools (dev builds only)

Gate everything behind `OS.is_debug_build()` or a `--dev` command-line flag so release builds are clean.

## Dev console (toggle with `` ` ``)
Autoload `DevConsole` with a command registry (mods can add commands too).
| Command | Effect |
|---|---|
| `god` | toggle invincibility |
| `noclip` | fly through walls |
| `spawn_bot <id> [count]` | spawn bots at crosshair |
| `kill_all` | kill every bot |
| `give <weapon_id>` | put a weapon in your inventory |
| `heal` / `hp <n>` | set health |
| `timescale <x>` | slow-mo or fast-forward (0.1 to 3) |
| `tp <x> <y> <z>` | teleport |
| `set <config.key> <value>` | live-edit movement/damage values |
| `reload_mods` | reload mods without restarting |
| `seed <n>` | deterministic randomness for repro |

## Debug overlays (F-keys)
- **F1** stats: FPS, speed, velocity vector, state (ground/air/dash/slam/chain), air jumps left
- **F2** hitboxes and raycasts (slice ray, chain path)
- **F3** bot AI: current state, target, path
- **F4** damage numbers floating over targets, with the momentum multiplier shown
- **F5-F8:** reserved for you

## Test scenes
Make `scenes/test/` with purpose-built rooms:
- `speed_run.tscn`: long straight, ramps, walls at set distances for crash-stop tuning
- `chain_range.tscn`: walls and pillars at varied angles for chain tests
- `bot_arena.tscn`: bots with chosen counts and behaviours
- `damage_dummy.tscn`: stationary target that logs damage per hit

## Record / replay
Log input per physics frame (`tick, move vector, buttons, mouse delta`) to a file and replay it. This gives you reproducible bug reports and feel comparisons ("same run, new tuning").

## Automated tests
Use the **GUT** addon (Godot Unit Test) for logic tests: damage formula, cooldowns, inventory ordering, registry/mod loading. Run headless: `godot --headless -s addons/gut/gut_cmdln.gd`.

## Tester feedback checklist
When a tester reports a bug they should include: build/version, active mods, steps, the `F1` stats screenshot, and the replay file if any.
