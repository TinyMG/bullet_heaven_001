extends CharacterBody2D

## Enemy.gd
## Chases the player. Has health. Drops XP gem on death.

@export var speed: float = 80.0
@export var max_hp: float = 20.0
@export var contact_damage: float = 10.0

var current_hp: float

var xp_gem_scene: PackedScene = preload("res://Entities/XPGem/XPGem.tscn")

@onready var sprite: Sprite2D = $Sprite2D
@onready var hitbox: Area2D = $Hitbox

func _ready() -> void:
	current_hp = max_hp
	add_to_group("Enemy")
	hitbox.add_to_group("EnemyHitbox")

func _physics_process(delta: float) -> void:
	var player = GameManager.player
	if player == null or GameManager.is_game_over:
		return
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	
	# Flip sprite
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0

func take_damage(amount: float) -> void:
	current_hp -= amount
	AudioManager.play_hit()
	# Flash effect
	sprite.modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
	
	if current_hp <= 0:
		_die()

func _die() -> void:
	# Spawn XP gem
	var gem = xp_gem_scene.instantiate()
	gem.global_position = global_position
	get_tree().current_scene.add_child.call_deferred(gem)
	
	GameManager.add_score(10)
	queue_free()


