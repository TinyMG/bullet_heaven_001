extends "res://Entities/Enemy/enemy.gd"

## FrostEnemy — leaves slow trails behind as it moves.

var frost_trail_scene: PackedScene = preload("res://Entities/Effects/FrostTrail.tscn")
var trail_cooldown: float = 0.8
var trail_timer: float = 0.0

func activate() -> void:
	super.activate()
	trail_timer = trail_cooldown

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if not visible:
		return
	trail_timer -= delta
	if trail_timer <= 0.0:
		trail_timer = trail_cooldown
		_spawn_trail()

func _spawn_trail() -> void:
	var trail = ObjectPool.get_instance(frost_trail_scene)
	trail.global_position = global_position
	if not trail.is_inside_tree():
		get_tree().current_scene.add_child.call_deferred(trail)
	else:
		trail.activate()
