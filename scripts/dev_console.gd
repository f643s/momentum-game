extends CanvasLayer
## Dev tools: console (`) and stats overlay (F1).
## Only active in debug builds or when launched with --dev.

const MIN_TIMESCALE: float = 0.1
const MAX_TIMESCALE: float = 3.0

## Noclip flight speed = walk_speed * this. Higher = faster flying.
var noclip_speed_mult: float = 3.0

var enabled: bool = false
var is_open: bool = false
var god: bool = false
var noclip: bool = false

var _commands: Dictionary = {}  # name -> {"call": Callable, "help": String}
var _history: Array[String] = []
var _history_index: int = 0
var _panel: PanelContainer
var _log: RichTextLabel
var _line: LineEdit
var _stats: Label


func _ready() -> void:
	enabled = OS.is_debug_build() \
		or "--dev" in OS.get_cmdline_args() \
		or "--dev" in OS.get_cmdline_user_args()
	layer = 100
	if not enabled:
		set_process(false)
		set_process_input(false)
		return
	_build_ui()
	_register_builtin_commands()
	_print_line("Dev console ready. Type 'help'.")


# ---------- public API (mods will use this later) ----------

func register_command(cmd_name: String, callable: Callable, help: String = "") -> void:
	_commands[cmd_name.to_lower()] = {"call": callable, "help": help}


func get_config(config_name: String) -> Resource:
	var p: CharacterBody3D = _player()
	if p == null:
		return null
	if config_name == "movement":
		return p.get("config") as Resource
	return null


# ---------- UI ----------

func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.visible = false
	_panel.custom_minimum_size = Vector2(0, 300)
	add_child(_panel)
	_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)

	var box := VBoxContainer.new()
	_panel.add_child(box)

	_log = RichTextLabel.new()
	_log.scroll_following = true
	_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(_log)

	_line = LineEdit.new()
	_line.placeholder_text = "command (try: help)"
	_line.text_submitted.connect(_on_submit)
	box.add_child(_line)

	_stats = Label.new()
	_stats.visible = false
	_stats.position = Vector2(20, 70)
	_stats.add_theme_constant_override("outline_size", 6)
	add_child(_stats)


func _print_line(text: String) -> void:
	_log.append_text(text + "\n")


func _set_open(value: bool) -> void:
	is_open = value
	_panel.visible = value
	if value:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		_line.clear()
		_line.grab_focus()
	else:
		_line.release_focus()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# ---------- input and per-frame ----------

func _input(event: InputEvent) -> void:
	# _input runs before the text box sees keys, so ` always toggles.
	if event.is_action_pressed("console_toggle"):
		_set_open(not is_open)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("debug_f1"):
		_stats.visible = not _stats.visible
	elif is_open and event is InputEventKey and event.pressed and not _history.is_empty():
		if event.keycode == KEY_UP:
			_history_index = maxi(_history_index - 1, 0)
			_line.text = _history[_history_index]
			_line.caret_column = _line.text.length()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_DOWN:
			_history_index = mini(_history_index + 1, _history.size())
			_line.text = "" if _history_index >= _history.size() else _history[_history_index]
			_line.caret_column = _line.text.length()
			get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	if not _stats.visible:
		return
	var text: String = "FPS: %d\n" % Engine.get_frames_per_second()
	var p: CharacterBody3D = _player()
	if p != null:
		var flat := Vector3(p.velocity.x, 0.0, p.velocity.z)
		text += "Speed: %.1f m/s\n" % flat.length()
		text += "Velocity: (%.1f, %.1f, %.1f)\n" % [p.velocity.x, p.velocity.y, p.velocity.z]
		text += "State: %s\n" % str(p.get("state_name"))
	text += "Timescale: %.2f" % Engine.time_scale
	if god:
		text += "\nGOD"
	_stats.text = text


func _player() -> CharacterBody3D:
	return get_tree().get_first_node_in_group("player") as CharacterBody3D


# ---------- command running ----------

func _on_submit(text: String) -> void:
	_line.clear()
	text = text.strip_edges()
	if text.is_empty():
		return
	_history.append(text)
	_history_index = _history.size()
	_print_line("> " + text)
	var parts: PackedStringArray = text.split(" ", false)
	var cmd: String = parts[0].to_lower()
	var args: Array = Array(parts.slice(1))
	if not _commands.has(cmd):
		_print_line("Unknown command. Type 'help'.")
		return
	var result: String = _commands[cmd]["call"].call(args)
	if not result.is_empty():
		_print_line(result)


func _register_builtin_commands() -> void:
	register_command("help", _cmd_help, "list commands")
	register_command("god", _cmd_god, "toggle invincibility")
	register_command("noclip", _cmd_noclip, "fly through walls (Space = up, look to go down)")
	register_command("timescale", _cmd_timescale, "timescale <0.1-3>")
	register_command("tp", _cmd_tp, "tp <x> <y> <z>")
	register_command("set", _cmd_set, "set movement.<key> <value>")


func _cmd_help(_args: Array) -> String:
	var names: Array = _commands.keys()
	names.sort()
	var out: String = ""
	for n in names:
		out += "  %s - %s\n" % [n, _commands[n]["help"]]
	return out.strip_edges(false, true)


func _cmd_god(_args: Array) -> String:
	god = not god
	return "God mode: %s (takes effect once health exists in Phase 4)" % ("ON" if god else "off")


func _cmd_noclip(_args: Array) -> String:
	noclip = not noclip
	if not noclip:
		var p: CharacterBody3D = _player()
		if p != null:
			p.velocity = Vector3.ZERO
	return "Noclip: %s" % ("ON" if noclip else "off")


func _cmd_timescale(args: Array) -> String:
	if args.size() < 1 or not String(args[0]).is_valid_float():
		return "Usage: timescale <%.1f to %.1f>" % [MIN_TIMESCALE, MAX_TIMESCALE]
	Engine.time_scale = clampf(String(args[0]).to_float(), MIN_TIMESCALE, MAX_TIMESCALE)
	return "Timescale: %.2f" % Engine.time_scale


func _cmd_tp(args: Array) -> String:
	if args.size() < 3 or not (String(args[0]).is_valid_float() \
			and String(args[1]).is_valid_float() and String(args[2]).is_valid_float()):
		return "Usage: tp <x> <y> <z>"
	var p: CharacterBody3D = _player()
	if p == null:
		return "No player in the scene."
	p.global_position = Vector3(
		String(args[0]).to_float(), String(args[1]).to_float(), String(args[2]).to_float())
	p.velocity = Vector3.ZERO
	return "Teleported."


func _cmd_set(args: Array) -> String:
	if args.size() < 2:
		return "Usage: set movement.<key> <value>   e.g. set movement.walk_speed 12"
	var parts: PackedStringArray = String(args[0]).split(".", false)
	if parts.size() != 2:
		return "Key must look like movement.walk_speed"
	var cfg: Resource = get_config(parts[0])
	if cfg == null:
		return "Unknown config '%s' (or no player in the scene)." % parts[0]
	var prop: String = parts[1]
	if not (prop in cfg):
		return "No setting called '%s'." % prop
	var value_text: String = String(args[1])
	match typeof(cfg.get(prop)):
		TYPE_FLOAT:
			if not value_text.is_valid_float():
				return "Expected a number."
			cfg.set(prop, value_text.to_float())
		TYPE_INT:
			if not value_text.is_valid_int():
				return "Expected a whole number."
			cfg.set(prop, value_text.to_int())
		_:
			return "Can't set that type yet."
	return "%s = %s" % [args[0], str(cfg.get(prop))]
