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
			GameManager.waves_completed.emit()

func _on_spawn_timer_timeout() -> void:
	if GameManager.is_game_over or waves_done:
		return

	# Check wave cap in finite mode
	if max_waves > 0 and current_wave >= max_waves:
		spawn_timer.stop()
		return

	current_wave += 1
	var count = base_enemies_per_wave + int(current_wave * 0.5)
	_spawn_wave(count)

	# Spawn boss on final wave in finite mode
	if boss_on_final_wave and current_wave == max_waves:
		_spawn_boss()

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

		var enemy = enemy_scene.instantiate()
		enemy.global_position = spawn_pos

		# Scale enemy HP
		enemy.max_hp = node_enemy_hp_base + (current_wave * node_enemy_hp_per_wave)
		# Apply difficulty modifier to speed
		enemy.speed *= node_difficulty

		get_tree().current_scene.add_child.call_deferred(enemy)

func _spawn_boss() -> void:
	var player = GameManager.player
	if player == null:
		return

	var angle = randf() * TAU
	var offset = Vector2(cos(angle), sin(angle)) * spawn_radius
	var spawn_pos = player.global_position + offset

	var boss = boss_scene.instantiate()
	boss.global_position = spawn_pos
	boss.speed *= node_difficulty
	active_boss = boss

	get_tree().current_scene.add_child.call_deferred(boss)

	# Notify boss HP bar
	var boss_bar = get_tree().current_scene.get_node_or_null("BossHPBar")
	if boss_bar and boss_bar.has_method("track_boss"):
		boss_bar.call_deferred("track_boss", boss)
