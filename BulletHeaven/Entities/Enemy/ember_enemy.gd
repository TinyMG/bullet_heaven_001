extends "res://Entities/Enemy/enemy.gd"

## EmberEnemy — periodically dash-charges toward the player.

var dash_cooldown: float = 3.0
var dash_timer: float = 0.0
var is_dashing: bool = false
var dash_duration: float = 0.3
var dash_elapsed: float = 0.0
var dash_speed: float = 280.0
var dash_direction: Vector2 = Vector2.ZERO
var _wind_up: bool = false

func activate() -> void:
	super.activate()
	dash_timer = dash_cooldown
	is_dashing = false
	_wind_up = false
	dash_elapsed = 0.0

func _physics_process(delta: float) -> void:
	if is_dashing:
		velocity = dash_direction * dash_speed
		move_and_slide()
		# Flip sprite based on dash direction
		if velocity.x != 0:
			sprite.flip_h = velocity.x < 0
		dash_elapsed += delta
		if dash_elapsed >= dash_duration:
			is_dashing = false
			dash_timer = dash_cooldown
			sprite.modulate = base_modulate
		# Still animate
		_tick_animation(delta)
		return

	if _wind_up:
		return

	super._physics_process(delta)
	dash_timer -= delta
	if dash_timer <= 0.0:
		_start_dash_windup()

func _start_dash_windup() -> void:
	_wind_up = true
	var player = GameManager.player
	if player == null:
		_wind_up = false
		dash_timer = dash_cooldown
		return
	dash_direction = (player.global_position - global_position).normalized()
	# Brief wind-up flash
	sprite.modulate = Color(1.0, 1.0, 0.5, 1.0)
	var tween = create_tween()
	tween.tween_interval(0.2)
	tween.tween_callback(_execute_dash)

func _execute_dash() -> void:
	_wind_up = false
	is_dashing = true
	dash_elapsed = 0.0
	sprite.modulate = Color(1.0, 0.8, 0.3, 1.0)

func _tick_animation(delta: float) -> void:
	anim_timer += delta
	if anim_timer >= anim_delay:
		anim_timer = 0.0
		anim_current = (anim_current + 1) % anim_frame_count
		sprite.frame = anim_frame_start + anim_current
