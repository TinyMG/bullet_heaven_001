extends Node

## WaveManager.gd
## Attached to a Timer node in Main. Spawns enemies in waves around the player.

@export var enemy_scene: PackedScene = preload("res://Entities/Enemy/Enemy.tscn")
@export var boss_scene: PackedScene = preload("res://Entities/Enemy/BossEnemy.tscn")
@export var spawn_radius: float = 500.0
@export var base_enemies_per_wave: int = 3
@export var wave_interval: float = 4.0  # seconds between waves
@export var boss_interval: float = 10.0  # seconds between boss spawn attempts

var current_wave: int = 0
var active_boss: CharacterBody2D = null

@onready var spawn_timer: Timer = $SpawnTimer

func _ready() -> void:
	spawn_timer.wait_time = wave_interval
	spawn_timer.start()
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	
	# Boss spawn timer
	var boss_timer = Timer.new()
	boss_timer.name = "BossTimer"
	boss_timer.wait_time = boss_interval
	boss_timer.autostart = true
	add_child(boss_timer)
	boss_timer.timeout.connect(_on_boss_timer_timeout)
	
	# Spawn first wave instantly
	_on_spawn_timer_timeout()

func _on_spawn_timer_timeout() -> void:
	if GameManager.is_game_over:
		return
	current_wave += 1
	var count = base_enemies_per_wave + int(current_wave * 0.5)
	_spawn_wave(count)

func _on_boss_timer_timeout() -> void:
	if GameManager.is_game_over:
		return
	# Only spawn a boss if there isn't one already alive
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
		
		# Scale enemy HP with wave number
		enemy.max_hp = 20.0 + (current_wave * 2.0)
		
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
	active_boss = boss
	
	get_tree().current_scene.add_child.call_deferred(boss)
	
	# Notify boss HP bar
	var boss_bar = get_tree().current_scene.get_node_or_null("BossHPBar")
	if boss_bar and boss_bar.has_method("track_boss"):
		boss_bar.call_deferred("track_boss", boss)
