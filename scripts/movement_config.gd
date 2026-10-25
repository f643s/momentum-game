class_name MovementConfig
extends Resource

## Walking speed in meters per second. Higher = faster running.
@export var walk_speed: float = 8.0
## Upward speed at the moment of a jump. Higher = bigger jump.
@export var jump_velocity: float = 9.0
## Downward pull in m/s^2. Higher = snappier, heavier falls.
@export var gravity: float = 25.0
## Radians of rotation per mouse pixel. Higher = twitchier look.
@export var mouse_sensitivity: float = 0.002
## Highest you can look up or down, in degrees.
@export var max_pitch_degrees: float = 89.0

@export_group("Momentum")
## How fast you speed up on the ground. Higher = snappier starts.
@export var ground_accel: float = 40.0
## How fast you slow down on the ground with no input. Lower = slidier.
@export var ground_friction: float = 18.0
## How strongly you can steer while airborne. Higher = more air control.
@export var air_accel: float = 25.0
## Speed lost per second in the air with no input. Near 0 = keeps momentum.
@export var air_friction: float = 0.5

@export_group("Speed FOV")
## Camera field of view at rest, in degrees.
@export var fov_base: float = 80.0
## Field of view at full speed. Bigger gap = stronger sense of speed.
@export var fov_max: float = 100.0
## Horizontal speed at which FOV reaches its max.
@export var fov_full_speed: float = 30.0
## How quickly FOV follows speed changes. Higher = snappier.
@export var fov_smoothing: float = 6.0
