extends Node

## ScreenShake Component
## Attach to a Camera2D. Call shake() to trigger screen shake.

@export var decay_rate: float = 5.0

var shake_intensity: float = 0.0
var shake_duration: float = 0.0
var shake_timer: float = 0.0

@onready var camera: Camera2D = get_parent()

func shake(intensity: float = 8.0, duration: float = 0.3) -> void:
	shake_intensity = intensity
	shake_duration = duration
	shake_timer = duration

func _process(delta: float) -> void:
	if shake_timer > 0.0:
		shake_timer -= delta
		var ratio = shake_timer / shake_duration
		var current_intensity = shake_intensity * ratio
		camera.offset = Vector2(
			randf_range(-current_intensity, current_intensity),
			randf_range(-current_intensity, current_intensity)
		)
	else:
		camera.offset = Vector2.ZERO
