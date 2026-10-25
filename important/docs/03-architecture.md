# Architecture

- **Player** (`CharacterBody3D`): owns velocity and a small state machine
  (GROUND, AIR, DASH, SLAM, CHAIN_PULL). Camera is a child on a pivot.
- **CameraRig**: mouse look, shake, punch, FOV kick. Exposes `add_shake(s)`, `punch(v)`, `kick_fov(d)`.
- **Health** (`Node` component): `hp`, `take_damage(amount, source)`, `heal(amount)`, signals `damaged`, `died`. Used by player and enemies.
- **Knockback**: any body with `apply_knockback(v: Vector3)`.
- **Weapons**: each a Node with `equip()`, `unequip()`, `use_pressed()`, `use_released()`. A `WeaponHolder` node owns the inventory array (6 slots) and the selected index.
- **Slicer**: reads mouse motion while `slice` is held, raycasts from the crosshair, deals damage.
- **GameFX** (autoload): `hitstop(duration)`, `spawn_impact(pos, normal, strength)`.
- Communication: signals up, method calls down.
