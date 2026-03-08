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
var anim_delay: float = 0.15

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
	velocity = input_vector * speed
	move_and_slide()
	
	# Flip sprite and animate based on movement
	if velocity.length() > 0.0:
		if velocity.x != 0:
			sprite.flip_h = velocity.x < 0
			
		anim_timer += delta
		if anim_timer >= anim_delay:
			anim_timer = 0.0
			sprite.frame = randi() % 72
	else:
		anim_timer = 0.0

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
	var proj = projectile_scene.instantiate()
	proj.global_position = muzzle.global_position
	var direction = (target.global_position - muzzle.global_position).normalized()
	proj.direction = direction
	proj.damage = base_damage + SkillsManager.get_skill_value("damage")
	AudioManager.play_shoot()
	get_tree().current_scene.add_child(proj)
	
	# Randomize sprite frame on shoot too
	sprite.frame = randi() % 72

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
	current_hp -= amount
	if current_hp <= 0:
		current_hp = 0
		GameManager.trigger_game_over()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("EnemyHitbox"):
		take_damage(10.0)


