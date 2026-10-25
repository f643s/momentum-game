extends CharacterBody3D

## The tuning file. Assign movement_config.tres in the Inspector.
@export var config: MovementConfig

@onready var pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var speed_label: Label = $HUD/SpeedLabel


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.fov = config.fov_base


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * config.mouse_sensitivity)
		var max_pitch: float = deg_to_rad(config.max_pitch_degrees)
		pivot.rotation.x = clampf(
			pivot.rotation.x - event.relative.y * config.mouse_sensitivity,
			-max_pitch, max_pitch)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= config.gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = config.jump_velocity

	var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "back")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()

	if is_on_floor():
		_move_ground(direction, delta)
	else:
		_move_air(direction, delta)

	move_and_slide()
	_update_feel(delta)


func _move_ground(direction: Vector3, delta: float) -> void:
	var horizontal := Vector3(velocity.x, 0.0, velocity.z)
	if direction != Vector3.ZERO:
		# Accelerate toward the wanted velocity.
		horizontal = horizontal.move_toward(direction * config.walk_speed, config.ground_accel * delta)
	else:
		# No input: friction slides you to a stop.
		horizontal = horizontal.move_toward(Vector3.ZERO, config.ground_friction * delta)
	velocity.x = horizontal.x
	velocity.z = horizontal.z


func _move_air(direction: Vector3, delta: float) -> void:
	var horizontal := Vector3(velocity.x, 0.0, velocity.z)
	if direction != Vector3.ZERO:
		# Only add speed toward the input up to walk_speed, so steering never
		# slows you down and fast momentum is kept.
		var current: float = horizontal.dot(direction)
		var add: float = clampf(config.walk_speed - current, 0.0, config.air_accel * delta)
		horizontal += direction * add
	else:
		horizontal = horizontal.move_toward(Vector3.ZERO, config.air_friction * delta)
	velocity.x = horizontal.x
	velocity.z = horizontal.z


func _update_feel(delta: float) -> void:
	var speed: float = Vector3(velocity.x, 0.0, velocity.z).length()
	var t: float = clampf(speed / config.fov_full_speed, 0.0, 1.0)
	var target_fov: float = lerpf(config.fov_base, config.fov_max, t)
	camera.fov = lerpf(camera.fov, target_fov, 1.0 - exp(-config.fov_smoothing * delta))
	speed_label.text = "Speed: %.1f m/s" % speed
