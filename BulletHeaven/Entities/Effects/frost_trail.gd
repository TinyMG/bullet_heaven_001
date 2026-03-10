extends Area2D

## FrostTrail — slows the player when they walk over it. Pool-compatible.

var lifetime: float = 4.0
var _ready_done: bool = false
var _fade_tween: Tween = null
var _expire_timer: float = 0.0

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	if not _ready_done:
		body_entered.connect(_on_body_entered)
		body_exited.connect(_on_body_exited)
		_ready_done = true
	activate()

func activate() -> void:
	visible = true
	set_physics_process(true)
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
	_expire_timer = lifetime
	if sprite:
		sprite.modulate.a = 1.0
	# Fade out visual over lifetime
	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.tween_property(sprite, "modulate:a", 0.0, lifetime)

func _physics_process(delta: float) -> void:
	_expire_timer -= delta
	if _expire_timer <= 0.0:
		_expire()

func _expire() -> void:
	# Remove slow from player if still overlapping
	for body in get_overlapping_bodies():
		if body.is_in_group("Player") and body.has_method("remove_slow"):
			body.remove_slow()
	_release()

func _release() -> void:
	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()
	visible = false
	set_physics_process(false)
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	ObjectPool.release_node.call_deferred(self)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body.has_method("apply_slow"):
		body.apply_slow()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player") and body.has_method("remove_slow"):
		body.remove_slow()
