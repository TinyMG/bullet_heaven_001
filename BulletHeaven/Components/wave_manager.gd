extends Node

## WaveManager.gd
## Spawns enemies in waves. Supports finite mode (from map nodes) and infinite mode (fallback).

@export var enemy_scene: PackedScene = preload("res://Entities/Enemy/Enemy.tscn")
@export var boss_scene: PackedScene = preload("res://Entities/Enemy/BossEnemy.tscn")
@export var spawn_radius: float = 500.0
@export var base_enemies_per_wave: int = 3
@export var wave_interval: float = 4.0
@export var boss_interval: float = 10.0

var current_wave: int = 0
var active_boss: CharacterBody2D = null

# Finite mode config (read from ProgressManager.current_node)
var max_waves: int = 0  # 0 = infinite mode
var node_enemy_hp_base: float = 20.0
var node_enemy_hp_per_wave: float = 2.0
var node_difficulty: float = 1.0
var boss_on_final_wave: bool = false
var waves_done: bool = false

@onready var spawn_timer: Timer = $SpawnTimer

func _ready() -> void:
	# Load config from current map node if available
	var node_data = ProgressManager.current_node
	if node_data != null:
		max_waves = node_data.wave_count
		base_enemies_per_wave = node_data.base_enemies_per_wave
		node_enemy_hp_base = node_data.enemy_hp_base
		node_enemy_hp_per_wave = node_data.enemy_hp_per_wave
		node_difficulty = node_data.difficulty_modifier
		boss_on_final_wave = node_data.boss_on_final_wave
		# Use custom enemy scene if configured
		var custom_path: String = node_data.get("enemy_scene_path")
		if custom_path != null and custom_path != "":
			enemy_scene = load(custom_path)

	# Apply node modifiers
	_apply_modifiers()

	spawn_timer.wait_time = wave_interval
	spawn_timer.start()
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

	# Boss spawn timer (only in infinite mode)
	if max_waves == 0:
		var boss_timer = Timer.new()
		boss_timer.name = "BossTimer"
		boss_timer.wait_time = boss_interval
		boss_timer.autostart = true
		add_child(boss_timer)
		boss_timer.timeout.connect(_on_boss_timer_timeout)

	# Spawn first wave instantly
	_on_spawn_timer_timeout()

func _process(_delta: float) -> void:
	# In finite mode, check if all waves are spawned and all enemies are dead
	if waves_done:
		return
	if max_waves > 0 and current_wave >= max_waves:
		var enemies = get_tree().get_nodes_in_group("Enemy")
		if enemies.is_empty():
			waves_done = true
			_show_wave_cleared_text()
			GameManager.waves_completed.emit()

func _on_spawn_timer_timeout() -> void:
	if GameManager.is_game_over or waves_done:
		return

	# Check wave cap in finite mode
	if max_waves > 0 and current_wave >= max_waves:
		spawn_timer.stop()
		return

	current_wave += 1
	_show_wave_text()
	var count = base_enemies_per_wave + int(current_wave * 0.5)
	_spawn_wave(count)

	# Spawn boss on final wave in finite mode
	if boss_on_final_wave and current_wave == max_waves:
		_spawn_boss()
		_show_wave_text_boss()

	# Stop timer after last wave
	if max_waves > 0 and current_wave >= max_waves:
		spawn_timer.stop()

func _on_boss_timer_timeout() -> void:
	if GameManager.is_game_over:
		return
	if active_boss != null and is_instance_valid(active_boss):
		return
	_spawn_boss()

func _spawn_wave(count: int) -> void:
	var player = GameManager.player
	if player == null:
		return

	for i in range(count):
		var angle = randf() * TAU
		var offset = Vector2(cos(angle), sin(angle)) * spawn_radius
		var spawn_pos = player.global_position + offset

		var enemy = ObjectPool.get_instance(enemy_scene)
		enemy.global_position = spawn_pos

		# Scale enemy HP
		enemy.max_hp = node_enemy_hp_base + (current_wave * node_enemy_hp_per_wave)
		# Apply difficulty modifier to speed
		enemy.speed *= node_difficulty

		if not enemy.is_inside_tree():
			get_tree().current_scene.add_child.call_deferred(enemy)
		else:
			enemy.activate()

func _spawn_boss() -> void:
	var player = GameManager.player
	if player == null:
		return

	var angle = randf() * TAU
	var offset = Vector2(cos(angle), sin(angle)) * spawn_radius
	var spawn_pos = player.global_position + offset

	var boss = ObjectPool.get_instance(boss_scene)
	boss.global_position = spawn_pos
	boss.speed *= node_difficulty
	active_boss = boss

	if not boss.is_inside_tree():
		get_tree().current_scene.add_child.call_deferred(boss)
	else:
		boss.activate()

	# Notify boss HP bar
	var boss_bar = get_tree().current_scene.get_node_or_null("BossHPBar")
	if boss_bar and boss_bar.has_method("track_boss"):
		boss_bar.call_deferred("track_boss", boss)

func _apply_modifiers() -> void:
	var mods = ProgressManager.active_modifiers
	if "tough_enemies" in mods:
		node_enemy_hp_base *= 1.5
		node_enemy_hp_per_wave *= 1.5
	if "fast_enemies" in mods:
		node_difficulty *= 1.4
	if "extra_waves" in mods:
		if max_waves > 0:
			max_waves += 2
	# "no_regen" is handled in player.gd

func _show_wave_cleared_text() -> void:
	var canvas = CanvasLayer.new()
	canvas.layer = 10

	var label = Label.new()
	label.text = "WAVES CLEARED!"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 42)
	label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4, 1.0))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	label.add_theme_constant_override("outline_size", 3)
	label.anchors_preset = Control.PRESET_CENTER
	label.anchor_left = 0.5
	label.anchor_right = 0.5
	label.anchor_top = 0.5
	label.anchor_bottom = 0.5
	label.offset_left = -200.0
	label.offset_right = 200.0
	label.offset_top = -30.0
	label.offset_bottom = 30.0
	label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	label.grow_vertical = Control.GROW_DIRECTION_BOTH
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(label)

	# Slide in from left
	label.position.x = -400
	label.modulate.a = 0.0
	get_tree().current_scene.add_child.call_deferred(canvas)

	var tween = label.create_tween()
	tween.tween_property(label, "position:x", 0.0, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.parallel().tween_property(label, "modulate:a", 1.0, 0.2)
	tween.tween_interval(1.5)
	tween.tween_property(label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(canvas.queue_free)

func _show_wave_text() -> void:
	var wave_text = ""
	if max_waves > 0:
		wave_text = "Wave %d / %d" % [current_wave, max_waves]
	else:
		wave_text = "Wave %d" % current_wave

	var canvas = CanvasLayer.new()
	canvas.layer = 10

	var label = Label.new()
	label.text = wave_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 36)
	label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	label.anchors_preset = Control.PRESET_CENTER_TOP
	label.anchor_left = 0.5
	label.anchor_right = 0.5
	label.offset_left = -150.0
	label.offset_right = 150.0
	label.offset_top = 80.0
	label.offset_bottom = 130.0
	label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(label)
	get_tree().current_scene.add_child.call_deferred(canvas)

	# Fade out after 1.5 seconds
	var tween = label.create_tween()
	tween.tween_interval(1.0)
	tween.tween_property(label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(canvas.queue_free)

func _show_wave_text_boss() -> void:
	var canvas = CanvasLayer.new()
	canvas.layer = 11

	var label = Label.new()
	label.text = "BOSS INCOMING!"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.2, 1.0))
	label.anchors_preset = Control.PRESET_CENTER_TOP
	label.anchor_left = 0.5
	label.anchor_right = 0.5
	label.offset_left = -150.0
	label.offset_right = 150.0
	label.offset_top = 120.0
	label.offset_bottom = 160.0
	label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(label)
	get_tree().current_scene.add_child.call_deferred(canvas)

	# Pulse then fade
	var tween = label.create_tween()
	tween.tween_property(label, "modulate:a", 0.4, 0.3)
	tween.tween_property(label, "modulate:a", 1.0, 0.3)
	tween.tween_property(label, "modulate:a", 0.4, 0.3)
	tween.tween_property(label, "modulate:a", 1.0, 0.3)
	tween.tween_interval(0.5)
	tween.tween_property(label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(canvas.queue_free)
