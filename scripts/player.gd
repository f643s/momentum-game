extends CharacterBody3D

## Fired when a slam lands. The mod API will forward this as player_slammed later.
signal slammed(pos: Vector3, power: float)

enum State { GROUND, AIR, DASH, SLAM }

const DASH_ACTIONS: Array = ["dash_f", "dash_l", "dash_r", "dash_b"]
const DASH_DIRS: Array = [Vector3.FORWARD, Vector3.LEFT, Vector3.RIGHT, Vector3.BACK]

## The tuning file. Assign movement_config.tres in the Inspector.
@export var config: MovementConfig

## Shown in the F1 overlay.
var state_name: String = "GROUND"
var air_jumps_left: int = 0
## Seconds left on each dash cooldown: forward, left, right, back.
var dash_timers: Array[float] = [0.0, 0.0, 0.0, 0.0]

var _state: State = State.GROUND
var _time: float = 0.0
var _jump_presses: Array[float] = []
var _dash_left: float = 0.0
var _dash_dir: Vector3 = Vector3.ZERO

@onready var pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var speed_label: Label = $HUD/SpeedLabel


func _ready() -> void:
	add_to_group("player")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.fov = config.fov_base


func _unhandled_input(event: InputEvent) -> void:
	if DevConsole.is_open:
		return

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
	if DevConsole.noclip:
		_fly(delta)
		_update_feel(delta)
		return

	_time += delta
	for i in dash_timers.size():
		dash_timers[i] = maxf(dash_timers[i] - delta, 0.0)

	# While the console is open, ignore game keys so typing doesn't move you.
	var direction := Vector3.ZERO
	if not DevConsole.is_open:
		var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "back")
		direction = (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
		_handle_dash_input()
		_handle_jump_input()

	match _state:
		State.DASH:
			_tick_dash(delta)
		State.SLAM:
			velocity = Vector3(0.0, -config.slam_fall_speed, 0.0)
		_:
			_tick_walk(direction, delta)

	move_and_slide()
	_after_move()
	_update_feel(delta)


func _handle_dash_input() -> void:
	if _state == State.DASH or _state == State.SLAM:
		return
	for i in DASH_ACTIONS.size():
		if Input.is_action_just_pressed(DASH_ACTIONS[i]) and dash_timers[i] <= 0.0:
			_dash_dir = transform.basis * DASH_DIRS[i]
			_dash_left = config.dash_duration
			dash_timers[i] = config.dash_cooldown
			_state = State.DASH
			return


func _handle_jump_input() -> void:
	if not Input.is_action_just_pressed("jump"):
		return
	# Remember recent presses; 3 inside the window mid-air = slam.
	_jump_presses.append(_time)
	while not _jump_presses.is_empty() and _time - _jump_presses[0] > config.slam_window:
		_jump_presses.pop_front()
	if _state == State.DASH or _state == State.SLAM:
		return
	if is_on_floor():
		velocity.y = config.jump_velocity
	elif _jump_presses.size() >= 3:
		_state = State.SLAM
		_jump_presses.clear()
	elif air_jumps_left > 0:
		air_jumps_left -= 1
		velocity.y = config.air_jump_velocity


func _tick_dash(delta: float) -> void:
	velocity = _dash_dir * config.dash_speed
	_dash_left -= delta
	if _dash_left <= 0.0:
		# Keep most of the speed so the dash flows into movement.
		velocity = _dash_dir * config.dash_speed * config.dash_exit_speed_mult
		_state = State.AIR


func _tick_walk(direction: Vector3, delta: float) -> void:
	if is_on_floor():
		_move_ground(direction, delta)
	else:
		velocity.y -= config.gravity * delta
		_move_air(direction, delta)


func _after_move() -> void:
	if is_on_floor():
		air_jumps_left = config.air_jumps
	if _state == State.SLAM and is_on_floor():
		Shockwave.blast(get_tree(), global_position, config.slam_radius,
			config.slam_knockback, config.slam_knockback_up)
		slammed.emit(global_position, config.slam_fall_speed)
		velocity = Vector3.ZERO
		_state = State.GROUND
	if _state != State.DASH and _state != State.SLAM:
		_state = State.GROUND if is_on_floor() else State.AIR
	state_name = str(State.keys()[_state])


func _fly(delta: float) -> void:
	state_name = "NOCLIP"
	var input_dir: Vector2 = Vector2.ZERO
	var up: float = 0.0
	if not DevConsole.is_open:
		input_dir = Input.get_vector("left", "right", "forward", "back")
		up = Input.get_action_strength("jump")
	# Uses the camera's facing, so looking down and pressing W flies down.
	var dir: Vector3 = pivot.global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)
	dir += Vector3.UP * up
	velocity = dir * config.walk_speed * DevConsole.noclip_speed_mult
	global_position += velocity * delta


func _move_ground(direction: Vector3, delta: float) -> void:
	var horizontal := Vector3(velocity.x, 0.0, velocity.z)
	if direction != Vector3.ZERO:
		horizontal = horizontal.move_toward(direction * config.walk_speed, config.ground_accel * delta)
	else:
		horizontal = horizontal.move_toward(Vector3.ZERO, config.ground_friction * delta)
	velocity.x = horizontal.x
	velocity.z = horizontal.z


func _move_air(direction: Vector3, delta: float) -> void:
	var horizontal := Vector3(velocity.x, 0.0, velocity.z)
	if direction != Vector3.ZERO:
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
