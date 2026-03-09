extends CharacterBody2D

## Enemy.gd
## Chases the player. Has health. Drops XP gem on death. Supports object pooling.

@export var speed: float = 80.0
@export var max_hp: float = 20.0
@export var contact_damage: float = 10.0
@export var is_boss: bool = false

var current_hp: float
var _default_speed: float = 80.0
var _ready_done: bool = false

var xp_gem_scene: PackedScene = preload("res://Entities/XPGem/XPGem.tscn")
var damage_number_scene: PackedScene = preload("res://Entities/DamageNumber/DamageNumber.tscn")
var death_effect_scene: PackedScene = preload("res://Entities/Effects/EnemyDeathEffect.tscn")
var loot_drop_scene: PackedScene = preload("res://Entities/LootDrop/LootDrop.tscn")

@onready var sprite: Sprite2D = $Sprite2D
@onready var hitbox: Area2D = $Hitbox

# Animation
var anim_timer: float = 0.0
var anim_delay: float = 0.2
var anim_frame_start: int = 0  # First frame in the walk row
var anim_frame_count: int = 6  # Frames per row
var anim_current: int = 0

func _ready() -> void:
	if not _ready_done:
		_default_speed = speed
		add_to_group("Enemy")
		hitbox.add_to_group("EnemyHitbox")
		_ready_done = true
	activate()

func activate() -> void:
	current_hp = max_hp
	visible = true
	set_physics_process(true)
	sprite.modulate = Color.WHITE
	# Re-enable collision
	set_deferred("collision_layer", 2)
	set_deferred("collision_mask", 1)
	hitbox.set_deferred("monitoring", true)
	hitbox.set_deferred("monitorable", true)
	# Randomize starting frame
	anim_current = randi() % anim_frame_count
	sprite.frame = anim_frame_start + anim_current

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
	
	# Walk animation cycle
	anim_timer += delta
	if anim_timer >= anim_delay:
		anim_timer = 0.0
		anim_current = (anim_current + 1) % anim_frame_count
		sprite.frame = anim_frame_start + anim_current

func take_damage(amount: float) -> void:
	current_hp -= amount
	AudioManager.play_hit()
	GameManager.add_damage_dealt(amount)
	
	# Spawn floating damage number
	var dmg_num = damage_number_scene.instantiate()
	dmg_num.call_deferred("setup", amount, global_position + Vector2(randf_range(-10, 10), -20))
	get_tree().current_scene.add_child.call_deferred(dmg_num)
	
	# Flash effect
	sprite.modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
	
	if current_hp <= 0:
		_die()

func _die() -> void:
	# Spawn death effect
	var effect = death_effect_scene.instantiate()
	effect.global_position = global_position
	effect.emitting = true
	if is_boss:
		# Bigger death effect for boss
		effect.amount = 30
		effect.scale = Vector2(3.0, 3.0)
		# Screen flash
		_boss_screen_flash()
		# Screen shake
		var camera = get_viewport().get_camera_2d()
		if camera:
			for child in camera.get_children():
				if child.has_method("shake"):
					child.shake(20.0, 0.6)
					break
	get_tree().current_scene.add_child.call_deferred(effect)
	# Auto-free the effect after its lifetime
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = true
	timer.autostart = true
	timer.timeout.connect(effect.queue_free)
	effect.add_child(timer)

	# Spawn XP gem
	var gem = ObjectPool.get_instance(xp_gem_scene)
	gem.global_position = global_position
	if not gem.is_inside_tree():
		get_tree().current_scene.add_child.call_deferred(gem)
	else:
		gem.activate()

	# Roll loot drops from current node's loot table
	_roll_loot()

	GameManager.add_score(50 if is_boss else 10)
	GameManager.add_kill()
	_release()

func _release() -> void:
	# Disable collision so we don't interact while pooled
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)
	set_physics_process(false)
	visible = false
	# Reset speed for next use
	speed = _default_speed
	ObjectPool.release_node.call_deferred(self)

func _roll_loot() -> void:
	var node_data = ProgressManager.current_node
	if node_data == null:
		return

	var loot_table: Array = []
	if is_boss:
		loot_table = node_data.boss_loot_table
	else:
		loot_table = node_data.enemy_loot_table

	for entry in loot_table:
		var chance: float = entry.get("drop_chance", 0.0)
		if randf() <= chance:
			var drop = ObjectPool.get_instance(loot_drop_scene)
			var offset = Vector2(randf_range(-15, 15), randf_range(-15, 15))
			drop.setup(entry["item_id"], global_position + offset)
			if not drop.is_inside_tree():
				get_tree().current_scene.add_child.call_deferred(drop)
			else:
				drop.activate()

func _boss_screen_flash() -> void:
	var flash = ColorRect.new()
	flash.color = Color(1, 1, 1, 0.8)
	flash.anchors_preset = Control.PRESET_FULL_RECT
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var canvas = CanvasLayer.new()
	canvas.layer = 100
	canvas.add_child(flash)
	get_tree().current_scene.add_child.call_deferred(canvas)
	# Fade out the flash
	var tween = flash.create_tween()
	tween.tween_property(flash, "color:a", 0.0, 0.4)
	tween.tween_callback(canvas.queue_free)
