extends "res://Entities/Enemy/enemy.gd"

## ShadeEnemy — teleports to a random position near the player periodically.

var blink_cooldown: float = 4.0
var blink_timer: float = 0.0
var blink_range: float = 150.0
var _is_blinking: bool = false

func activate() -> void:
	super.activate()
	blink_timer = blink_cooldown
	_is_blinking = false

func _physics_process(delta: float) -> void:
	if _is_blinking:
		return
	super._physics_process(delta)
	blink_timer -= delta
	if blink_timer <= 0.0:
		_start_blink()

func _start_blink() -> void:
	var player = GameManager.player
	if player == null:
		blink_timer = blink_cooldown
		return
	_is_blinking = true
	var tween = create_tween()
	# Fade out
	tween.tween_property(sprite, "modulate:a", 0.0, 0.15)
	tween.tween_callback(func():
		# Teleport near player
		var angle = randf() * TAU
		var offset = Vector2(cos(angle), sin(angle)) * randf_range(60.0, blink_range)
		global_position = player.global_position + offset
	)
	# Fade in
	tween.tween_property(sprite, "modulate:a", base_modulate.a, 0.15)
	tween.tween_callback(func():
		sprite.modulate = base_modulate
		_is_blinking = false
		blink_timer = blink_cooldown
	)
