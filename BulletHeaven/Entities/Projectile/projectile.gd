extends Area2D

## Projectile.gd
## Flies in a direction and damages enemies on contact. Supports object pooling.

@export var speed: float = 400.0
var direction: Vector2 = Vector2.RIGHT
var damage: float = 10.0
var lifetime: float = 3.0
var pierce_count: int = 0
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
	# Re-enable collision
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	_lifetime_timer -= delta
	if _lifetime_timer <= 0.0:
		_release()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy") and body.has_method("take_damage"):
		body.take_damage(damage)
		if PlayerStats.volatile_active:
			_volatile_explode(body)
		if pierce_count <= 0:
			_release()
		else:
			pierce_count -= 1

func _volatile_explode(hit_body: Node2D) -> void:
	var aoe_damage = damage * 0.4
	var radius_sq = 1600.0  # radius squared (40^2)
	var enemies = get_tree().get_nodes_in_group("Enemy")
	for enemy in enemies:
		if enemy == hit_body:
			continue
		if enemy.global_position.distance_squared_to(global_position) <= radius_sq:
			if enemy.has_method("take_damage"):
				enemy.take_damage(aoe_damage)
	# Small visual burst
	var particles = CPUParticles2D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = 8
	particles.lifetime = 0.25
	particles.direction = Vector2.ZERO
	particles.spread = 180.0
	particles.initial_velocity_min = 20.0
	particles.initial_velocity_max = 50.0
	particles.gravity = Vector2.ZERO
	particles.scale_amount_min = 1.5
	particles.scale_amount_max = 3.0
	particles.color = Color(1.0, 0.6, 0.1, 0.8)
	var gradient = Gradient.new()
	gradient.set_color(0, Color(1.0, 0.6, 0.1, 0.8))
	gradient.set_color(1, Color(1.0, 0.3, 0.0, 0.0))
	particles.color_ramp = gradient
	particles.global_position = global_position
	get_tree().current_scene.add_child(particles)
	get_tree().create_timer(0.5).timeout.connect(particles.queue_free)

func _release() -> void:
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	set_physics_process(false)
	visible = false
	ObjectPool.release_node.call_deferred(self)
