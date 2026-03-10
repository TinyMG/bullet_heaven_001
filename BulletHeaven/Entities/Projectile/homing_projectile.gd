extends Area2D

## HomingProjectile — curves toward the nearest enemy.

@export var speed: float = 350.0
var direction: Vector2 = Vector2.RIGHT
var damage: float = 10.0
var lifetime: float = 3.0
var pierce_count: int = 0
var turn_speed: float = 3.0
var _lifetime_timer: float = 0.0
var _ready_done: bool = false

func _ready() -> void:
	if not _ready_done:
		add_to_group("Projectile")
		collision_layer = 4
		collision_mask = 2
		body_entered.connect(_on_body_entered)
		_ready_done = true
	activate()

func activate() -> void:
	visible = true
	set_physics_process(true)
	_lifetime_timer = lifetime
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)

func _physics_process(delta: float) -> void:
	# Home toward nearest enemy
	var nearest = _find_nearest_enemy()
	if nearest:
		var desired_dir = (nearest.global_position - global_position).normalized()
		var angle_diff = direction.angle_to(desired_dir)
		var max_turn = turn_speed * delta
		var clamped = clamp(angle_diff, -max_turn, max_turn)
		direction = direction.rotated(clamped).normalized()

	position += direction * speed * delta
	rotation = direction.angle()
	_lifetime_timer -= delta
	if _lifetime_timer <= 0.0:
		_release()

func _find_nearest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("Enemy")
	var closest: Node2D = null
	var closest_dist: float = 400.0
	for enemy in enemies:
		var dist = global_position.distance_to(enemy.global_position)
		if dist < closest_dist:
			closest = enemy
			closest_dist = dist
	return closest

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy") and body.has_method("take_damage"):
		body.take_damage(damage)
		if pierce_count <= 0:
			_release()
		else:
			pierce_count -= 1

func _release() -> void:
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	set_physics_process(false)
	visible = false
	ObjectPool.release_node.call_deferred(self)
