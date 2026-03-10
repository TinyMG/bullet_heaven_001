extends CharacterBody2D

## Enemy.gd
## Chases the player. Has health. Drops XP gem on death. Supports object pooling.

@export var speed: float = 80.0
@export var max_hp: float = 20.0
@export var contact_damage: float = 10.0
@export var is_boss: bool = false
@export var base_modulate: Color = Color.WHITE

# Multi-sheet animation (optional — if set, overrides single sprite sheet)
@export var idle_texture: Texture2D = null
@export var move_texture: Texture2D = null
@export var death_texture: Texture2D = null
@export var sheet_hframes: int = 6
@export var sheet_vframes: int = 6

var current_hp: float
var _default_speed: float = 80.0
var _default_contact_damage: float = 10.0
var _ready_done: bool = false

# Knockback state
var _knockback_velocity: Vector2 = Vector2.ZERO
var _knockback_timer: float = 0.0

# Boss phase system — phases trigger at 75%, 50%, 25% HP
var boss_phase: int = 0  # 0 = full, 1 = 75%, 2 = 50%, 3 = 25%
var _boss_hp_bar: ProgressBar = null
var _boss_phase_label: Label = null

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
var _uses_multi_sheet: bool = false
var _current_anim: String = ""  # "idle", "move", "death"

func _ready() -> void:
	if not _ready_done:
		_default_speed = speed
		_default_contact_damage = contact_damage
		add_to_group("Enemy")
		hitbox.add_to_group("EnemyHitbox")
		_ready_done = true
	activate()

func activate() -> void:
	current_hp = max_hp
	visible = true
	set_physics_process(true)
	_knockback_velocity = Vector2.ZERO
	_knockback_timer = 0.0
	sprite.modulate = base_modulate
	# Re-add to groups (removed on release for pool)
	if not is_in_group("Enemy"):
		add_to_group("Enemy")
	if not hitbox.is_in_group("EnemyHitbox"):
		hitbox.add_to_group("EnemyHitbox")
	# Re-enable collision
	set_deferred("collision_layer", 2)
	set_deferred("collision_mask", 1)
	hitbox.set_deferred("monitoring", true)
	hitbox.set_deferred("monitorable", true)
	# Detect multi-sheet animation
	_uses_multi_sheet = (idle_texture != null and move_texture != null)
	if _uses_multi_sheet:
		_set_anim("idle")
	# Randomize starting frame
	anim_current = randi() % anim_frame_count
	sprite.frame = anim_frame_start + anim_current
	# Reset boss phase
	if is_boss:
		boss_phase = 0
		contact_damage = _default_contact_damage
		_setup_boss_hp_bar()

func _physics_process(delta: float) -> void:
	var player = GameManager.player
	if player == null or GameManager.is_game_over:
		return

	# Knockback overrides chase movement
	if _knockback_timer > 0.0:
		_knockback_timer -= delta
		_knockback_velocity = _knockback_velocity.lerp(Vector2.ZERO, 5.0 * delta)
		velocity = _knockback_velocity
		move_and_slide()
		return

	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	
	# Flip sprite
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0
	
	# Switch animation sheet based on movement
	if _uses_multi_sheet:
		if velocity.length() > 5.0:
			_set_anim("move")
		else:
			_set_anim("idle")

	# Walk animation cycle
	anim_timer += delta
	if anim_timer >= anim_delay:
		anim_timer = 0.0
		anim_current = (anim_current + 1) % anim_frame_count
		sprite.frame = anim_frame_start + anim_current

func apply_knockback(direction: Vector2, force: float = 350.0, duration: float = 0.25) -> void:
	_knockback_velocity = direction * force
	_knockback_timer = duration

func take_damage(amount: float) -> void:
	current_hp -= amount
	AudioManager.play_hit()
	GameManager.add_damage_dealt(amount)

	# Spawn floating damage number (pooled)
	var dmg_num = ObjectPool.get_instance(damage_number_scene)
	if not dmg_num.is_inside_tree():
		get_tree().current_scene.add_child.call_deferred(dmg_num)
	dmg_num.call_deferred("setup", amount, global_position + Vector2(randf_range(-10, 10), -20))

	# Flash effect
	sprite.modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", base_modulate, 0.1)

	# Update overhead HP bar
	if is_boss and _boss_hp_bar:
		_boss_hp_bar.value = current_hp

	# Check boss phase transitions
	if is_boss:
		_check_boss_phase()

	if current_hp <= 0:
		_die()

func _die() -> void:
	# Spawn death effect (pooled)
	var effect = ObjectPool.get_instance(death_effect_scene)
	effect.global_position = global_position
	if not effect.is_inside_tree():
		get_tree().current_scene.add_child.call_deferred(effect)
	effect.call_deferred("activate", is_boss)
	if is_boss:
		# Screen flash
		_boss_screen_flash()
		# Screen shake
		var camera = get_viewport().get_camera_2d()
		if camera:
			for child in camera.get_children():
				if child.has_method("shake"):
					child.shake(20.0, 0.6)
					break

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
	if is_boss:
		GameManager.boss_defeated.emit()

	# Play death animation if multi-sheet, then release
	if _uses_multi_sheet and death_texture:
		_play_death_anim()
	else:
		_release()

func _play_death_anim() -> void:
	# Stop movement and collision, but stay visible for death anim
	set_physics_process(false)
	set_deferred("collision_layer", 0)
	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)
	if is_in_group("Enemy"):
		remove_from_group("Enemy")

	_set_anim("death")
	# Play only the first row of frames at fast speed
	var total_frames = sheet_hframes
	var frame_time = 0.05
	var tween = create_tween()
	for i in range(total_frames):
		tween.tween_callback(func(): sprite.frame = i)
		tween.tween_interval(frame_time)
	# Fade out at the end
	tween.tween_property(sprite, "modulate:a", 0.0, 0.15)
	tween.tween_callback(_release)

func _release() -> void:
	# Clean up overhead boss HP bar
	if _boss_hp_bar:
		_boss_hp_bar.queue_free()
		_boss_hp_bar = null
	if _boss_phase_label:
		_boss_phase_label.queue_free()
		_boss_phase_label = null
	# Remove from groups so WaveManager doesn't count pooled enemies as alive
	if is_in_group("Enemy"):
		remove_from_group("Enemy")
	if hitbox.is_in_group("EnemyHitbox"):
		hitbox.remove_from_group("EnemyHitbox")
	# Disable collision so we don't interact while pooled
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)
	set_physics_process(false)
	visible = false
	# Reset speed and damage for next use
	speed = _default_speed
	contact_damage = _default_contact_damage
	_current_anim = ""
	ObjectPool.release_node.call_deferred(self)

func _set_anim(anim_name: String) -> void:
	if _current_anim == anim_name:
		return
	_current_anim = anim_name
	match anim_name:
		"idle":
			if idle_texture:
				sprite.texture = idle_texture
				sprite.hframes = sheet_hframes
				sprite.vframes = sheet_vframes
				anim_frame_count = sheet_hframes
				anim_frame_start = 0
		"move":
			if move_texture:
				sprite.texture = move_texture
				sprite.hframes = sheet_hframes
				sprite.vframes = sheet_vframes
				anim_frame_count = sheet_hframes
				anim_frame_start = 0
		"death":
			if death_texture:
				sprite.texture = death_texture
				sprite.hframes = sheet_hframes
				sprite.vframes = sheet_vframes
				anim_frame_count = sheet_hframes
				anim_frame_start = 0
	anim_current = 0
	sprite.frame = anim_frame_start

func _roll_loot() -> void:
	var node_data = ProgressManager.current_node
	if node_data == null:
		return

	var loot_table: Array = []
	if is_boss:
		loot_table = node_data.boss_loot_table
	else:
		loot_table = node_data.enemy_loot_table

	var drop_bonus: float = ProgressManager.get_total_drop_bonus()
	for entry in loot_table:
		var chance: float = entry.get("drop_chance", 0.0) + drop_bonus
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

# ── Boss Phase System ──

func _check_boss_phase() -> void:
	var hp_pct = current_hp / max_hp
	var new_phase = 0
	if hp_pct <= 0.25:
		new_phase = 3
	elif hp_pct <= 0.50:
		new_phase = 2
	elif hp_pct <= 0.75:
		new_phase = 1

	if new_phase > boss_phase:
		boss_phase = new_phase
		_on_phase_change(boss_phase)

func _on_phase_change(phase: int) -> void:
	# Each phase: +20% speed, +15% contact damage
	speed = _default_speed * (1.0 + phase * 0.2)
	contact_damage = _default_contact_damage * (1.0 + phase * 0.15)

	# Phase transition screen shake (smaller than death shake)
	var camera = get_viewport().get_camera_2d()
	if camera:
		for child in camera.get_children():
			if child.has_method("shake"):
				child.shake(10.0, 0.3)
				break

	# Flash boss sprite a warning color per phase
	var phase_color = [Color.WHITE, Color.YELLOW, Color.ORANGE, Color.RED][phase]
	sprite.modulate = phase_color
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", base_modulate, 0.4)

	# Update phase label
	if _boss_phase_label:
		_boss_phase_label.text = "Phase %d" % (phase + 1)

# ── Boss Overhead HP Bar ──

func _setup_boss_hp_bar() -> void:
	# Clean up existing bar if any
	if _boss_hp_bar:
		_boss_hp_bar.queue_free()
	if _boss_phase_label:
		_boss_phase_label.queue_free()

	# Create HP bar as child of boss (moves with boss automatically)
	var bar = ProgressBar.new()
	bar.max_value = max_hp
	bar.value = current_hp
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(16, 2)
	bar.size = Vector2(16, 2)
	# Position above boss head (boss is scale 5, sprite ~64px, so offset in local coords)
	bar.position = Vector2(-8, -10)
	# Style the bar
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	bg_style.corner_radius_top_left = 1
	bg_style.corner_radius_top_right = 1
	bg_style.corner_radius_bottom_left = 1
	bg_style.corner_radius_bottom_right = 1
	bar.add_theme_stylebox_override("background", bg_style)

	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color(0.9, 0.1, 0.1, 0.9)
	fill_style.corner_radius_top_left = 1
	fill_style.corner_radius_top_right = 1
	fill_style.corner_radius_bottom_left = 1
	fill_style.corner_radius_bottom_right = 1
	bar.add_theme_stylebox_override("fill", fill_style)

	add_child(bar)
	_boss_hp_bar = bar

	# Phase label below HP bar
	var label = Label.new()
	label.text = "Phase 1"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(-8, -8)
	label.custom_minimum_size = Vector2(16, 0)
	label.add_theme_font_size_override("font_size", 3)
	label.add_theme_color_override("font_color", Color.WHITE)
	add_child(label)
	_boss_phase_label = label
