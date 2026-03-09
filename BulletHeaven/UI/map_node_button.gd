extends Control

## MapNodeButton
## A clickable node on the world map. Displays lock/complete/available state.

signal node_selected(data: Resource)

var node_data: Resource = null
var _region_locked: bool = false

@onready var button: Button = $Button
@onready var label: Label = $Label
@onready var status_label: Label = $StatusLabel

func setup(data: Resource) -> void:
	node_data = data

func set_locked_region(locked: bool) -> void:
	_region_locked = locked

func _ready() -> void:
	if node_data == null:
		return
	label.text = node_data.display_name
	button.pressed.connect(_on_pressed)
	_update_state()

var _glow_tween: Tween = null

func _update_state() -> void:
	# Kill any existing glow
	if _glow_tween and _glow_tween.is_valid():
		_glow_tween.kill()
		_glow_tween = null

	if ProgressManager.is_node_completed(node_data.node_id):
		button.modulate = Color(0.4, 1.0, 0.4)
		status_label.text = "CLEAR"
		status_label.add_theme_color_override("font_color", Color(0.2, 0.9, 0.3))
	elif ProgressManager.is_node_unlocked(node_data):
		button.modulate = Color(1.0, 1.0, 1.0)
		status_label.text = "NEW"
		status_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
		_start_glow()
	else:
		button.modulate = Color(0.4, 0.4, 0.4)
		status_label.text = "LOCKED"
		status_label.add_theme_color_override("font_color", Color(0.7, 0.3, 0.3))

func _start_glow() -> void:
	_glow_tween = create_tween()
	_glow_tween.set_loops()
	_glow_tween.tween_property(button, "modulate", Color(1.0, 0.9, 0.4), 0.8).set_ease(Tween.EASE_IN_OUT)
	_glow_tween.tween_property(button, "modulate", Color(1.0, 1.0, 1.0), 0.8).set_ease(Tween.EASE_IN_OUT)

func _on_pressed() -> void:
	if _region_locked:
		return  # Can't interact with nodes from locked regions
	node_selected.emit(node_data)
