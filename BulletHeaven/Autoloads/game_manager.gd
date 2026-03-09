extends Node

## GameManager Autoload
## Manages global game state: score, player reference, game over logic.

signal score_changed(new_score: int)
signal game_over
signal player_leveled_up(new_level: int)
signal waves_completed

var score: int = 0
var player: CharacterBody2D = null
var is_game_over: bool = false

# XP / Level
var current_xp: int = 0
var current_level: int = 1
var xp_to_next_level: int = 10  # Base XP required

# Stats
var elapsed_time: float = 0.0
var total_kills: int = 0
var total_damage_dealt: float = 0.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if not is_game_over:
		elapsed_time += delta

func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)

func add_xp(amount: int) -> void:
	if is_game_over:
		return
	current_xp += amount
	while current_xp >= xp_to_next_level:
		current_xp -= xp_to_next_level
		current_level += 1
		xp_to_next_level = _calculate_xp_for_level(current_level)
		player_leveled_up.emit(current_level)

func _calculate_xp_for_level(level: int) -> int:
	# XP curve: each level needs more XP
	return int(10 * pow(level, 1.2))

func add_kill() -> void:
	total_kills += 1

func add_damage_dealt(amount: float) -> void:
	total_damage_dealt += amount

func trigger_game_over() -> void:
	if is_game_over:
		return
	is_game_over = true
	game_over.emit()

func reset() -> void:
	score = 0
	current_xp = 0
	current_level = 1
	xp_to_next_level = 10
	is_game_over = false
	elapsed_time = 0.0
	total_kills = 0
	total_damage_dealt = 0.0

func get_time_string() -> String:
	var minutes = int(elapsed_time) / int(60)
	var seconds = int(elapsed_time) % int(60)
	return "%02d:%02d" % [minutes, seconds]

