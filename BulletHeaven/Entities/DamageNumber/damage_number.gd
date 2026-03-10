extends Node2D

## DamageNumber.gd
## Floating damage text that rises and fades out. Pool-compatible.

@onready var label: Label = $Label

var _ready_done: bool = false

func setup(value: float, pos: Vector2, is_crit: bool = false) -> void:
	global_position = pos
	visible = true

	if not _ready_done:
		# Will be handled in _ready
		label = get_node("Label")

	label.text = str(int(value))
	label.modulate.a = 1.0

	if is_crit:
		label.add_theme_font_size_override("font_size", 24)
		label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.0))
	else:
		label.add_theme_font_size_override("font_size", 16)
		label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))

	# Float up and fade
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 40, 0.8).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.8).set_delay(0.3)
	tween.chain().tween_callback(_release)

func _ready() -> void:
	_ready_done = true

func activate() -> void:
	visible = true

func _release() -> void:
	visible = false
	ObjectPool.release_node.call_deferred(self)
