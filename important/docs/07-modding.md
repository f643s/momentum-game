# Modding and API (build this in from day one)

Decision: the first demo is **bots only**. Modding and tester tools are developed alongside the game, not bolted on at the end.

## Golden rule: be data-driven
If a weapon, enemy, or tuning value is hard-coded inside a script, mods cannot touch it. From Phase 1 onward:
- Tuning numbers live in a `Resource` (e.g. `MovementConfig.tres`), not as constants in `player.gd`.
- Weapons, bots, and items are defined by `Resource` files (`WeaponDef`, `BotDef`, `ItemDef`) and registered by id string: `"base:gold_chains"`.
- Gameplay code asks a **registry** for things instead of preloading them.

## How external mods load (Godot-native)
Mods are `.pck` (or `.zip`) packs placed in `user://mods/` (on Linux: `~/.local/share/godot/app_userdata/<project>/mods/`).

```gdscript
# autoload: ModLoader.gd
func load_all() -> void:
    var dir := DirAccess.open("user://mods")
    if dir == null: return
    for f in dir.get_files():
        if f.ends_with(".pck") or f.ends_with(".zip"):
            if ProjectSettings.load_resource_pack("user://mods/" + f):
                _init_mod(f)
```

Each mod contains a `mod.json` manifest:
```json
{ "id": "examplemod", "name": "Example", "version": "0.1.0",
  "api_version": 1, "entry": "res://mods/examplemod/main.gd",
  "depends": [] }
```
`ModLoader` reads the manifest, checks `api_version`, loads `entry`, and calls `init(api)`.

```gdscript
# a mod's main.gd
extends RefCounted
func init(api) -> void:
    api.register_weapon("examplemod:rocket_chain", preload("res://mods/examplemod/rocket_chain.tres"))
    api.events.player_slammed.connect(func(pos, power): print("slam at ", pos))
```

## Mod API surface (autoload `ModAPI`, versioned)
Keep it small and stable. Version it (`API_VERSION := 1`) and never break old versions silently.
- **Registries:** `register_weapon`, `register_bot`, `register_item`, `register_sound`
- **Events (signals):** `player_spawned`, `player_damaged`, `bot_died`, `player_slammed`, `chain_fired`, `chain_teleported`, `hard_stop`, `slice_hit`, `round_started`
- **Hooks (can modify values):** `modify_damage(ctx)`, `modify_movement(ctx)` where `ctx` is a Dictionary the mod may edit
- **Queries:** `get_player()`, `get_bots()`, `get_config("movement")`
- **Commands:** `register_command("name", callable)` adds to the dev console
- **Logging:** `api.log(mod_id, msg)`

## Safety note
GDScript mods run with full game permissions (files, OS). For a private/dev build that is fine. If you ever distribute mods publicly, either state clearly "only install mods you trust" or restrict mods to data-only (JSON/Resources, no scripts).

## Mod phases
- **M1:** configs and defs become Resources + registries (no mod loading yet)
- **M2:** `ModLoader` + `mod.json` + loading a `.pck` from `user://mods/`
- **M3:** events and hooks in `ModAPI`
- **M4:** example mod in `mods_example/` (a new weapon) as living documentation
- **M5:** mod docs in `docs/modding-guide.md` for outside modders
