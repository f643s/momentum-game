extends CharacterBody3D
## A stationary target. Anything with apply_knockback() in the "knockable" group can be pushed.

## Downward pull in m/s^2.
@export var gravity: float = 25.0
## How fast it slows down on the ground. Lower = slides farther.
@export var friction: float = 8.0


func _ready() -> void:
	add_to_group("knockable")


func apply_knockback(v: Vector3) -> void:
	velocity += v


func _physics_process(delta: float) -> void:
	if is_on_floor():
		var flat := Vector3(velocity.x, 0.0, velocity.z).move_toward(Vector3.ZERO, friction * delta)
		velocity.x = flat.x
		velocity.z = flat.z
	else:
		velocity.y -= gravity * delta
	move_and_slide()
