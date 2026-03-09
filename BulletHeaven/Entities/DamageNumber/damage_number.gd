extends Node2D

## DamageNumber.gd
## Floating damage text that rises and fades out.

@onready var label: Label = $Label

var _value: float = 0.0
var _pos: Vector2 = Vector2.ZERO
var _is_crit: bool = false

func setup(value: float, pos: Vector2, is_crit: bool = false) -> void:
	_value = value
	_pos = pos
	_is_crit = is_crit

func _ready() -> void:
	global_position = _pos
	label.text = str(int(_value))
	
	if _is_crit:
		label.add_theme_font_size_override("font_size", 24)
		label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.0))
	
	# Float up and fade
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 40, 0.8).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.8).set_delay(0.3)
	tween.chain().tween_callback(queue_free)
