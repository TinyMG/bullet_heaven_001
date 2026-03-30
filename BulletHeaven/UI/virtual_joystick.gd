extends CanvasLayer

## VirtualJoystick
## On-screen touch joystick for mobile. Feeds into Input actions so
## player.gd works identically with keyboard or touch.

@onready var base: Control = $Base
@onready var knob: Control = $Base/Knob
@onready var boost_button: Button = $BoostButton

var is_pressed: bool = false
var touch_index: int = -1
var joystick_radius: float = 64.0
var dead_zone: float = 0.15

# Output vector (0-1 range per axis)
var output: Vector2 = Vector2.ZERO

func _ready() -> void:
	layer = 5
	joystick_radius = base.size.x * 0.5
	knob.pivot_offset = knob.size * 0.5
	_reset_knob()

	boost_button.button_down.connect(_on_boost_down)
	boost_button.button_up.connect(_on_boost_up)

	# Only show on touch devices (or always for testing)
	if not _is_touch_device():
		visible = false

func _is_touch_device() -> bool:
	return OS.has_feature("mobile") or OS.has_feature("web") or OS.has_feature("android") or OS.has_feature("ios")

func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event
		if touch.pressed:
			# Only capture if touching the left half of screen (joystick side)
			if touch.position.x < get_viewport().get_visible_rect().size.x * 0.5:
				if not is_pressed:
					is_pressed = true
					touch_index = touch.index
					_move_base_to(touch.position)
					_update_knob(touch.position)
		else:
			if touch.index == touch_index:
				_release()

	elif event is InputEventScreenDrag:
		var drag: InputEventScreenDrag = event
		if drag.index == touch_index and is_pressed:
			_update_knob(drag.position)

func _move_base_to(screen_pos: Vector2) -> void:
	base.global_position = screen_pos - base.size * 0.5

func _update_knob(screen_pos: Vector2) -> void:
	var center = base.global_position + base.size * 0.5
	var diff = screen_pos - center
	var dist_sq = diff.length_squared()
	var joystick_radius_sq = joystick_radius * joystick_radius

	if dist_sq > joystick_radius_sq:
		diff = diff.normalized() * joystick_radius

	knob.global_position = center + diff - knob.size * 0.5

	# Calculate output
	output = diff / joystick_radius
	if output.length_squared() < (dead_zone * dead_zone):
		output = Vector2.ZERO

	_apply_input()

func _release() -> void:
	is_pressed = false
	touch_index = -1
	output = Vector2.ZERO
	_reset_knob()
	_apply_input()
	# Reset base to default position
	base.position = Vector2(20, -148)  # Bottom-left area

func _reset_knob() -> void:
	knob.position = (base.size - knob.size) * 0.5

func _apply_input() -> void:
	# Release all directions first
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("move_up")
	Input.action_release("move_down")

	if output.x < -dead_zone:
		Input.action_press("move_left", -output.x)
	elif output.x > dead_zone:
		Input.action_press("move_right", output.x)

	if output.y < -dead_zone:
		Input.action_press("move_up", -output.y)
	elif output.y > dead_zone:
		Input.action_press("move_down", output.y)

func _on_boost_down() -> void:
	Input.action_press("boost")

func _on_boost_up() -> void:
	Input.action_release("boost")
