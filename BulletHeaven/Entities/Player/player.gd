extends CharacterBody2D

## Player.gd
## 8-way movement + auto-firing weapon targeting the nearest enemy.

@export var base_speed: float = 150.0
@export var base_damage: float = 10.0
@export var base_fire_rate: float = 0.5  # seconds between shots (fallback)

@onready var fire_timer: Timer = $FireTimer
@onready var muzzle: Marker2D = $Muzzle
@onready var sprite: Sprite2D = $Sprite2D
@onready var magnet_area: Area2D = $MagnetArea
@onready var magnet_collision: CollisionShape2D = $MagnetArea/CollisionShape2D
@onready var hurtbox: Area2D = $Hurtbox

var projectile_scene: PackedScene = preload("res://Entities/Projectile/Projectile.tscn")
var homing_projectile_scene: PackedScene = preload("res://Entities/Projectile/HomingProjectile.tscn")
var aoe_projectile_scene: PackedScene = preload("res://Entities/Projectile/AoEProjectile.tscn")

var max_hp: float = 100.0
var current_hp: float = 100.0
var base_magnet_radius: float = 120.0

var anim_timer: float = 0.0
var anim_delay: float = 0.1
var anim_current: int = 0

var shoot_anim_timer: float = 0.0

enum AnimState {
	IDLE, RUN, SHOOT, BOOST
}
var current_anim_state: AnimState = AnimState.IDLE
var _prev_anim_state: AnimState = AnimState.IDLE

# Number of actual frames per animation row in the sprite sheet
const ANIM_FRAME_COUNTS: Dictionary = {
	AnimState.IDLE: 6,
	AnimState.RUN: 10,
	AnimState.SHOOT: 6,
	AnimState.BOOST: 6,
}

# I-frames
var is_invincible: bool = false
var invincibility_duration: float = 1.0
var blink_tween: Tween = null
var contact_damage_cooldown: float = 0.0
var contact_damage_interval: float = 0.5  # seconds between contact damage ticks

# Slow debuff (from frost trails)
var slow_stack_count: int = 0
var speed_modifier: float = 1.0

# Cached stat values (updated on skill upgrade / equip change, not every frame)
var _cached_hp_regen: float = 0.0

func _ready() -> void:
	GameManager.player = self
	add_to_group("Player")
	fire_timer.wait_time = base_fire_rate
	fire_timer.start()
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	_update_magnet_radius()

	# Connect skill upgrades and level-up effects
	SkillsManager.skill_upgraded.connect(_on_skill_upgraded)
	GameManager.player_leveled_up.connect(_on_leveled_up)

	# Connect hurtbox
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)

	# Listen for PlayerStats changes (covers equipment + level-up stat boosts)
	PlayerStats.stats_changed.connect(_on_stats_changed)

	# Apply stats at combat start
	_apply_stats_from_player_stats()
	_update_cached_stats()
	current_hp = max_hp

func _physics_process(delta: float) -> void:
	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var speed = PlayerStats.final_speed
	
	var is_boosting = Input.is_action_pressed("boost")
	if is_boosting:
		speed *= 1.5
		
	velocity = input_vector * speed * speed_modifier
	move_and_slide()
	
	# Determine state — BOOST takes priority over SHOOT so auto-fire doesn't flicker
	shoot_anim_timer -= delta
	if is_boosting and velocity.length_squared() > 0.0:
		current_anim_state = AnimState.BOOST
	elif shoot_anim_timer > 0.0:
		current_anim_state = AnimState.SHOOT
	elif velocity.length_squared() > 0.0:
		current_anim_state = AnimState.RUN
	else:
		current_anim_state = AnimState.IDLE

	# Flip sprite handling
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0
	elif current_anim_state == AnimState.SHOOT:
		var nearest = _find_nearest_enemy()
		if nearest and nearest.global_position.x < global_position.x:
			sprite.flip_h = true
		elif nearest:
			sprite.flip_h = false

	# Get row, frame count, and speed for current state
	var row: int = 0
	var frame_count: int = 10
	var anim_speed: float = anim_delay
	var static_frame: int = -1  # -1 means animate, >= 0 means lock to that column
	match current_anim_state:
		AnimState.IDLE:
			row = 0; frame_count = 6
		AnimState.RUN:
			row = 1; frame_count = 10
		AnimState.SHOOT:
			row = 2; frame_count = 6
		AnimState.BOOST:
			row = 3; static_frame = 2  # Lock to frame 2 of boost row

	# Reset frame counter when animation state changes
	if current_anim_state != _prev_anim_state:
		anim_current = 0
		anim_timer = 0.0
		_prev_anim_state = current_anim_state
		if static_frame >= 0:
			sprite.frame = row * 10 + static_frame
		else:
			sprite.frame = row * 10

	# Advance animation (skip if static frame)
	if static_frame < 0:
		anim_timer += delta
		if anim_timer >= anim_speed:
			anim_timer = 0.0
			anim_current = (anim_current + 1) % frame_count
			sprite.frame = row * 10 + anim_current
	
	# HP regen from skills + equipment (disabled by no_regen modifier)
	if "no_regen" not in ProgressManager.active_modifiers:
		var regen = _cached_hp_regen
		if regen > 0.0 and current_hp < max_hp:
			current_hp = min(current_hp + regen * delta, max_hp)

	# Continuous contact damage from overlapping enemies
	if contact_damage_cooldown > 0.0:
		contact_damage_cooldown -= delta
	elif not is_invincible:
		var overlapping = hurtbox.get_overlapping_areas()
		for area in overlapping:
			if area.is_in_group("EnemyHitbox"):
				var enemy = area.get_parent()
				var dmg = enemy.contact_damage if enemy.has_method("take_damage") else 10.0
				take_damage(dmg)
				_push_enemy(enemy)
				break  # Only take damage from one enemy per tick

func _get_anim_row(state: AnimState) -> int:
	match state:
		AnimState.IDLE:  return 0
		AnimState.RUN:   return 1
		AnimState.SHOOT: return 2
		AnimState.BOOST: return 3
	return 0

func _on_fire_timer_timeout() -> void:
	var nearest = _find_nearest_enemy()
	if nearest == null:
		return
	_fire_at(nearest)

func _find_nearest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("Enemy")
	var closest: Node2D = null
	var closest_dist_sq: float = 250000.0  # 500.0 squared, max targeting range
	for enemy in enemies:
		var dist_sq = global_position.distance_squared_to(enemy.global_position)
		if dist_sq < closest_dist_sq:
			closest = enemy
			closest_dist_sq = dist_sq
	return closest

func _get_weapon_type() -> String:
	if ProgressManager.equipped_weapon == "":
		return "standard"
	var data = ItemDatabase.get_item(ProgressManager.equipped_weapon)
	return data.get("weapon_type", "standard")

func _fire_at(target: Node2D) -> void:
	var weapon_type = _get_weapon_type()
	match weapon_type:
		"spread": _fire_spread(target)
		"piercing": _fire_piercing(target)
		"homing": _fire_homing(target)
		"aoe": _fire_aoe(target)
		_: _fire_standard(target)
	AudioManager.play_shoot()
	shoot_anim_timer = 0.2

func _get_damage() -> float:
	return PlayerStats.final_power

func _get_pierce() -> int:
	return int(SkillsManager.get_skill_value("projectile_pierce") + ProgressManager.get_equipment_stat("projectile_pierce"))

func _get_projectile_count() -> int:
	return 1 + int(SkillsManager.get_skill_value("projectile_count") + ProgressManager.get_equipment_stat("projectile_count"))

func _fire_standard(target: Node2D) -> void:
	var base_direction = (target.global_position - muzzle.global_position).normalized()
	var total = _get_projectile_count()
	var spread_angle = deg_to_rad(10.0)
	for i in range(total):
		var proj = ObjectPool.get_instance(projectile_scene)
		proj.global_position = muzzle.global_position
		var offset_angle = 0.0
		if total > 1:
			offset_angle = (i - (total - 1) / 2.0) * spread_angle
		proj.direction = base_direction.rotated(offset_angle)
		proj.damage = _get_damage()
		proj.pierce_count = _get_pierce()
		if not proj.is_inside_tree():
			get_tree().current_scene.add_child(proj)
		else:
			proj.activate()

func _fire_spread(target: Node2D) -> void:
	var base_direction = (target.global_position - muzzle.global_position).normalized()
	var total = _get_projectile_count() + 2  # Extra projectiles for spread
	var spread_angle = deg_to_rad(25.0)  # Wider spread
	for i in range(total):
		var proj = ObjectPool.get_instance(projectile_scene)
		proj.global_position = muzzle.global_position
		var offset_angle = (i - (total - 1) / 2.0) * spread_angle
		proj.direction = base_direction.rotated(offset_angle)
		proj.damage = _get_damage() * 0.7  # Less damage per bolt
		proj.pierce_count = _get_pierce()
		proj.lifetime = 1.5  # Shorter range
		if not proj.is_inside_tree():
			get_tree().current_scene.add_child(proj)
		else:
			proj.activate()

func _fire_piercing(target: Node2D) -> void:
	var base_direction = (target.global_position - muzzle.global_position).normalized()
	var total = _get_projectile_count()
	var spread_angle = deg_to_rad(10.0)
	for i in range(total):
		var proj = ObjectPool.get_instance(projectile_scene)
		proj.global_position = muzzle.global_position
		var offset_angle = 0.0
		if total > 1:
			offset_angle = (i - (total - 1) / 2.0) * spread_angle
		proj.direction = base_direction.rotated(offset_angle)
		proj.damage = _get_damage()
		proj.pierce_count = 9999  # Infinite pierce
		if not proj.is_inside_tree():
			get_tree().current_scene.add_child(proj)
		else:
			proj.activate()

func _fire_homing(target: Node2D) -> void:
	var base_direction = (target.global_position - muzzle.global_position).normalized()
	var total = _get_projectile_count()
	var spread_angle = deg_to_rad(15.0)
	for i in range(total):
		var proj = ObjectPool.get_instance(homing_projectile_scene)
		proj.global_position = muzzle.global_position
		var offset_angle = 0.0
		if total > 1:
			offset_angle = (i - (total - 1) / 2.0) * spread_angle
		proj.direction = base_direction.rotated(offset_angle)
		proj.damage = _get_damage()
		proj.pierce_count = _get_pierce()
		if not proj.is_inside_tree():
			get_tree().current_scene.add_child(proj)
		else:
			proj.activate()

func _fire_aoe(target: Node2D) -> void:
	var base_direction = (target.global_position - muzzle.global_position).normalized()
	var total = _get_projectile_count()
	var spread_angle = deg_to_rad(10.0)
	for i in range(total):
		var proj = ObjectPool.get_instance(aoe_projectile_scene)
		proj.global_position = muzzle.global_position
		var offset_angle = 0.0
		if total > 1:
			offset_angle = (i - (total - 1) / 2.0) * spread_angle
		proj.direction = base_direction.rotated(offset_angle)
		proj.damage = _get_damage()
		if not proj.is_inside_tree():
			get_tree().current_scene.add_child(proj)
		else:
			proj.activate()

func _on_skill_upgraded(_skill_name: String, _new_rank: int) -> void:
	_update_cached_stats()

func _on_stats_changed() -> void:
	_apply_stats_from_player_stats()

func _apply_stats_from_player_stats() -> void:
	var old_max_hp = max_hp
	max_hp = PlayerStats.final_vitality
	# Heal proportionally when max HP increases from a level-up stat boost
	if max_hp > old_max_hp and old_max_hp > 0.0:
		current_hp = min(current_hp + (max_hp - old_max_hp), max_hp)
	# Fire rate: convert attacks-per-second to seconds-between-shots
	fire_timer.wait_time = maxf(0.1, 1.0 / PlayerStats.final_attack_speed)

func _update_magnet_radius() -> void:
	var radius = base_magnet_radius + PlayerStats.magnetic_bonus
	(magnet_collision.shape as CircleShape2D).radius = radius

func on_enemy_killed() -> void:
	if PlayerStats.vampiric_active and current_hp < max_hp:
		current_hp = minf(current_hp + 3.0, max_hp)

func _update_cached_stats() -> void:
	_cached_hp_regen = SkillsManager.get_skill_value("hp_regen") + ProgressManager.get_equipment_stat("hp_regen")

func take_damage(amount: float) -> void:
	if is_invincible:
		return
	current_hp -= amount
	contact_damage_cooldown = contact_damage_interval

	# Hit flash (red)
	sprite.modulate = Color.RED
	var flash_tween = create_tween()
	flash_tween.tween_property(sprite, "modulate", Color.WHITE, 0.15)

	# Screen shake
	var camera = get_viewport().get_camera_2d()
	if camera:
		for child in camera.get_children():
			if child.has_method("shake"):
				child.shake(10.0, 0.3)
				break

	if current_hp <= 0:
		current_hp = 0
		GameManager.trigger_game_over()
	else:
		_start_invincibility()

func _start_invincibility() -> void:
	is_invincible = true
	
	# Blink effect
	if blink_tween and blink_tween.is_valid():
		blink_tween.kill()
	blink_tween = create_tween()
	blink_tween.set_loops(int(invincibility_duration / 0.15))
	blink_tween.tween_property(sprite, "modulate:a", 0.3, 0.075)
	blink_tween.tween_property(sprite, "modulate:a", 1.0, 0.075)
	
	# Timer to end invincibility
	var timer = get_tree().create_timer(invincibility_duration)
	timer.timeout.connect(_end_invincibility)

func _end_invincibility() -> void:
	is_invincible = false
	sprite.modulate = Color.WHITE
	if blink_tween and blink_tween.is_valid():
		blink_tween.kill()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("EnemyHitbox") and not is_invincible:
		var enemy = area.get_parent()
		var dmg = enemy.contact_damage if enemy.has_method("take_damage") else 10.0
		take_damage(dmg)
		_push_enemy(enemy)

func _on_leveled_up(_new_level: int) -> void:
	_spawn_level_up_burst()

func _spawn_level_up_burst() -> void:
	var particles = CPUParticles2D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = 24
	particles.lifetime = 0.6
	particles.direction = Vector2.ZERO
	particles.spread = 180.0
	particles.initial_velocity_min = 80.0
	particles.initial_velocity_max = 160.0
	particles.gravity = Vector2.ZERO
	particles.scale_amount_min = 3.0
	particles.scale_amount_max = 5.0
	particles.color = Color(1.0, 0.9, 0.2, 1.0)
	var gradient = Gradient.new()
	gradient.set_color(0, Color(1.0, 0.9, 0.2, 1.0))
	gradient.set_color(1, Color(0.2, 1.0, 0.4, 0.0))
	particles.color_ramp = gradient
	particles.global_position = global_position
	get_tree().current_scene.add_child(particles)
	# Auto-cleanup after particles finish
	get_tree().create_timer(1.0).timeout.connect(particles.queue_free)

func _push_enemy(enemy: Node2D) -> void:
	if enemy.has_method("apply_knockback"):
		var push_dir = (enemy.global_position - global_position).normalized()
		enemy.apply_knockback(push_dir, 350.0, 0.25)

func apply_slow() -> void:
	slow_stack_count += 1
	speed_modifier = max(0.3, 1.0 - slow_stack_count * 0.15)

func remove_slow() -> void:
	slow_stack_count = max(0, slow_stack_count - 1)
	speed_modifier = max(0.3, 1.0 - slow_stack_count * 0.15)
