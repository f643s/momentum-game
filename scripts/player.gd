extends CharacterBody3D

## The tuning file. Assign movement_config.tres in the Inspector.
@export var config: MovementConfig

@onready var pivot: Node3D = $CameraPivot


func _ready() -> void:
	# Safety net: if the config resource was never assigned, fall back to defaults
	# so the player still moves instead of crashing.
	if config == null:
		config = MovementConfig.new()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	# Esc frees the mouse, clicking the window captures it again.
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Left/right turns the whole body, up/down tilts only the camera pivot.
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
	velocity.x = direction.x * config.walk_speed
	velocity.z = direction.z * config.walk_speed

	move_and_slide()
