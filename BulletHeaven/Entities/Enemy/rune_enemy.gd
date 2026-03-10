extends "res://Entities/Enemy/enemy.gd"

## RuneEnemy — fires projectiles at the player periodically.

var enemy_projectile_scene: PackedScene = preload("res://Entities/Projectile/EnemyProjectile.tscn")
var shoot_cooldown: float = 2.5
var shoot_timer: float = 0.0
var projectile_damage: float = 8.0

func activate() -> void:
	super.activate()
	shoot_timer = shoot_cooldown

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if not visible:
		return
	shoot_timer -= delta
	if shoot_timer <= 0.0:
		shoot_timer = shoot_cooldown
		_fire_at_player()

func _fire_at_player() -> void:
	var player = GameManager.player
	if player == null:
		return
	var dir = (player.global_position - global_position).normalized()
	# Fire 3 projectiles in a small spread
	var spread = deg_to_rad(15.0)
	for i in range(3):
		var offset_angle = (i - 1) * spread
		var proj = ObjectPool.get_instance(enemy_projectile_scene)
		proj.global_position = global_position
		proj.direction = dir.rotated(offset_angle)
		proj.damage = projectile_damage
		if not proj.is_inside_tree():
			get_tree().current_scene.add_child(proj)
		else:
			proj.activate()
