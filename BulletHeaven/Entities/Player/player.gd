extends CharacterBody2D

## Player.gd
## 8-way movement + auto-firing weapon targeting the nearest enemy.

@export var base_speed: float = 200.0
@export var base_damage: float = 10.0
@export var base_fire_rate: float = 0.5  # seconds between shots

@onready var fire_timer: Timer = $FireTimer
@onready var muzzle: Marker2D = $Muzzle
@onready var sprite: Sprite2D = $Sprite2D
@onready var magnet_area: Area2D = $MagnetArea
@onready var magnet_collision: CollisionShape2D = $MagnetArea/CollisionShape2D
@onready var hurtbox: Area2D = $Hurtbox

var projectile_scene: PackedScene = preload("res://Entities/Projectile/Projectile.tscn")

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

# I-frames
var is_invincible: bool = false
var invincibility_duration: float = 1.0
var blink_tween: Tween = null
var contact_damage_cooldown: float = 0.0
var contact_damage_interval: float = 0.5  # seconds between contact damage ticks

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

	# Apply equipment stats at combat start
	_update_fire_rate()
	_update_max_hp()
	current_hp = max_hp

func _physics_process(delta: float) -> void:
	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var speed = base_speed + SkillsManager.get_skill_value("move_speed") + ProgressManager.get_equipment_stat("move_speed")
	
	var is_boosting = Input.is_key_pressed(KEY_SHIFT) or Input.is_physical_key_pressed(KEY_SHIFT)
	if is_boosting:
		speed *= 1.5
		
	velocity = input_vector * speed
	move_and_slide()
	
	# Determine state
	shoot_anim_timer -= delta
	if shoot_anim_timer > 0.0:
		current_anim_state = AnimState.SHOOT
	elif is_boosting and velocity.length() > 0.0:
		current_anim_state = AnimState.BOOST
	elif velocity.length() > 0.0:
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

	# Play animation
	anim_timer += delta
	if anim_timer >= anim_delay:
		anim_timer = 0.0
		anim_current = (anim_current + 1) % 10
		var row = 0
		if current_anim_state == AnimState.IDLE:     row = 0
		elif current_anim_state == AnimState.RUN:    row = 1
		elif current_anim_state == AnimState.SHOOT:  row = 2
		elif current_anim_state == AnimState.BOOST:  row = 3
		
		# set frame
		sprite.frame = (row * 10) + anim_current
	
	# HP regen from skills + equipment
	var regen = SkillsManager.get_skill_value("hp_regen") + ProgressManager.get_equipment_stat("hp_regen")
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

func _on_fire_timer_timeout() -> void:
	var nearest = _find_nearest_enemy()
	if nearest == null:
		return
	_fire_at(nearest)

func _find_nearest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("Enemy")
	var closest: Node2D = null
	var closest_dist: float = 500.0  # Max targeting range
	for enemy in enemies:
		var dist = global_position.distance_to(enemy.global_position)
		if dist < closest_dist:
			closest = enemy
			closest_dist = dist
	return closest

func _fire_at(target: Node2D) -> void:
	var base_direction = (target.global_position - muzzle.global_position).normalized()
	var extra_projectiles = int(SkillsManager.get_skill_value("projectile_count") + ProgressManager.get_equipment_stat("projectile_count"))
	var total = 1 + extra_projectiles
	var spread_angle = deg_to_rad(10.0)  # 10 degrees between each extra projectile
	
	for i in range(total):
		var proj = ObjectPool.get_instance(projectile_scene)
		proj.global_position = muzzle.global_position

		# Calculate spread offset
		var offset_angle = 0.0
		if total > 1:
			offset_angle = (i - (total - 1) / 2.0) * spread_angle
		var direction = base_direction.rotated(offset_angle)

		proj.direction = direction
		proj.damage = base_damage + SkillsManager.get_skill_value("damage") + ProgressManager.get_equipment_stat("damage")
		proj.pierce_count = int(SkillsManager.get_skill_value("projectile_pierce") + ProgressManager.get_equipment_stat("projectile_pierce"))
		if not proj.is_inside_tree():
			get_tree().current_scene.add_child(proj)
		else:
			proj.activate()
	
	AudioManager.play_shoot()
	
	shoot_anim_timer = 0.2

func _on_skill_upgraded(skill_name: String, _new_rank: int) -> void:
	match skill_name:
		"fire_rate":
			_update_fire_rate()
		"pickup_radius":
			_update_magnet_radius()
		"max_hp":
			_update_max_hp()
			current_hp = min(current_hp + 10.0, max_hp)  # Heal a bit on upgrade

func _update_fire_rate() -> void:
	var reduction = SkillsManager.get_skill_value("fire_rate") + ProgressManager.get_equipment_stat("fire_rate")
	fire_timer.wait_time = max(0.1, base_fire_rate - (base_fire_rate * reduction))

func _update_max_hp() -> void:
	var bonus = SkillsManager.get_skill_value("max_hp") + ProgressManager.get_equipment_stat("max_hp")
	max_hp = 100.0 + bonus

func _update_magnet_radius() -> void:
	var radius = base_magnet_radius + SkillsManager.get_skill_value("pickup_radius")
	(magnet_collision.shape as CircleShape2D).radius = radius

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
	if enemy is CharacterBody2D:
		var push_dir = (enemy.global_position - global_position).normalized()
		enemy.velocity = push_dir * 200.0
		enemy.move_and_slide()
