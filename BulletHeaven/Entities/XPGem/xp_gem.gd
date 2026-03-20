extends Area2D

## XPGem.gd
## Dropped by enemies. Flies toward the player when within magnet range. Supports object pooling.

@export var xp_value: int = 1
@export var magnet_speed: float = 300.0

var is_magnetized: bool = false
var target: Node2D = null
var _ready_done: bool = false

func _ready() -> void:
	if not _ready_done:
		add_to_group("XPGem")
		collision_layer = 8
		collision_mask = 1
		area_entered.connect(_on_area_entered)
		_ready_done = true
	activate()

func activate() -> void:
	is_magnetized = false
	target = null
	visible = true
	set_physics_process(true)
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)

func _physics_process(delta: float) -> void:
	if is_magnetized and target and is_instance_valid(target):
		var dir = (target.global_position - global_position).normalized()
		position += dir * magnet_speed * delta

		# If close enough, collect
		# Optimization: Use distance_squared_to to avoid expensive square root calculations
		if global_position.distance_squared_to(target.global_position) < 100.0:
			_collect()

func _on_area_entered(area: Area2D) -> void:
	# When the player's MagnetArea touches us
	var parent = area.get_parent()
	if parent and parent.is_in_group("Player"):
		is_magnetized = true
		target = parent

func _collect() -> void:
	GameManager.add_xp(xp_value)
	_release()

func _release() -> void:
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	set_physics_process(false)
	visible = false
	ObjectPool.release_node.call_deferred(self)
