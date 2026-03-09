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
var base_magnet_radius: float = 60.0

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

func _ready() -> void:
	GameManager.player = self
	add_to_group("Player")
	fire_timer.wait_time = base_fire_rate
	fire_timer.start()
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	_update_magnet_radius()
	
	# Connect skill upgrades
	SkillsManager.skill_upgraded.connect(_on_skill_upgraded)
	
	# Connect hurtbox
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)

func _physics_process(delta: float) -> void:
	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var speed = base_speed + SkillsManager.get_skill_value("move_speed")
	
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
	
	# HP regen from skills
	var regen = SkillsManager.get_skill_value("hp_regen")
	if regen > 0.0 and current_hp < max_hp:
		current_hp = min(current_hp + regen * delta, max_hp)

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
	var extra_projectiles = int(SkillsManager.get_skill_value("projectile_count"))
	var total = 1 + extra_projectiles
	var spread_angle = deg_to_rad(10.0)  # 10 degrees between each extra projectile
	
	for i in range(total):
		var proj = projectile_scene.instantiate()
		proj.global_position = muzzle.global_position
		
		# Calculate spread offset
		var offset_angle = 0.0
		if total > 1:
			offset_angle = (i - (total - 1) / 2.0) * spread_angle
		var direction = base_direction.rotated(offset_angle)
		
		proj.direction = direction
		proj.damage = base_damage + SkillsManager.get_skill_value("damage")
		proj.pierce_count = int(SkillsManager.get_skill_value("projectile_pierce"))
		get_tree().current_scene.add_child(proj)
	
	AudioManager.play_shoot()
	
	shoot_anim_timer = 0.2

func _on_skill_upgraded(skill_name: String, _new_rank: int) -> void:
	match skill_name:
		"fire_rate":
			var reduction = SkillsManager.get_skill_value("fire_rate")
			fire_timer.wait_time = max(0.1, base_fire_rate - (base_fire_rate * reduction))
		"pickup_radius":
			_update_magnet_radius()
		"max_hp":
			var bonus = SkillsManager.get_skill_value("max_hp")
			max_hp = 100.0 + bonus
			current_hp = min(current_hp + 10.0, max_hp)  # Heal a bit on upgrade

func _update_magnet_radius() -> void:
	var radius = base_magnet_radius + SkillsManager.get_skill_value("pickup_radius")
	(magnet_collision.shape as CircleShape2D).radius = radius

func take_damage(amount: float) -> void:
	if is_invincible:
		return
	current_hp -= amount
	
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
	if area.is_in_group("EnemyHitbox"):
		take_damage(10.0)
