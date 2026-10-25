# Setup (Arch Linux)

```bash
sudo pacman -S godot git
# graphics (pick yours): vulkan-radeon | vulkan-intel | nvidia-utils
sudo pacman -S vulkan-tools && vulkaninfo --summary   # if it fails, use Compatibility renderer
```

## Project
1. Godot > New Project > name `momentum-game` > renderer Forward+ (or Compatibility on weak GPUs).
2. `git init` in the project folder, add a `.gitignore` containing `.godot/`.
3. Push to GitHub after Phase 0.

## Folder layout
```
res://
  scenes/   (world.tscn, player.tscn, enemy_dummy.tscn, weapons/)
  scripts/  (player.gd, camera_rig.gd, health.gd, weapons/...)
  fx/       (particles, decals)
  audio/
  ui/
  mods_example/  (example mod used as documentation)
  addons/gut/    (unit tests)
```

## Input Map actions to create (Project > Project Settings > Input Map)
left, right, forward, back, jump, dash_f, dash_l, dash_r, dash_b,
slot_1, slot_2, slot_3, slice (left mouse), use (right mouse)

## Extra Input Map actions for dev tools
console_toggle (`), debug_f1 ... debug_f4
