extends Area2D

## AoEProjectile — explodes on contact, damaging all enemies in a radius.

@export var speed: float = 400.0
var direction: Vector2 = Vector2.RIGHT
var damage: float = 10.0
var lifetime: float = 3.0
var pierce_count: int = 0
var explosion_radius: float = 60.0
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
	position += direction * speed * delta
	_lifetime_timer -= delta
	if _lifetime_timer <= 0.0:
		_release()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy") and body.has_method("take_damage"):
		_explode()

func _explode() -> void:
	# Damage all enemies in radius
	var explosion_radius_sq = explosion_radius * explosion_radius
	var enemies = get_tree().get_nodes_in_group("Enemy")
	for enemy in enemies:
		if global_position.distance_squared_to(enemy.global_position) <= explosion_radius_sq:
			if enemy.has_method("take_damage"):
				enemy.take_damage(damage * 0.7)
	# Visual explosion
	var particles = CPUParticles2D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = 16
	particles.lifetime = 0.4
	particles.direction = Vector2.ZERO
	particles.spread = 180.0
	particles.initial_velocity_min = 40.0
	particles.initial_velocity_max = 100.0
	particles.gravity = Vector2.ZERO
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 4.0
	particles.color = Color(1.0, 0.7, 0.2, 1.0)
	var gradient = Gradient.new()
	gradient.set_color(0, Color(1.0, 0.7, 0.2, 1.0))
	gradient.set_color(1, Color(1.0, 0.3, 0.0, 0.0))
	particles.color_ramp = gradient
	particles.global_position = global_position
	get_tree().current_scene.add_child(particles)
	get_tree().create_timer(0.8).timeout.connect(particles.queue_free)
	_release()

func _release() -> void:
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	set_physics_process(false)
	visible = false
	ObjectPool.release_node.call_deferred(self)
