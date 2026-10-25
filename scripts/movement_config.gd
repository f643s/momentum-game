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
