extends CanvasLayer

## HUD.gd
## Displays score, HP bar, XP bar, level, timer, and kill count.

@onready var score_label: Label = $MarginContainer/VBoxContainer/ScoreLabel
@onready var kills_label: Label = $MarginContainer/VBoxContainer/KillsLabel
@onready var hp_bar: ProgressBar = $MarginContainer/VBoxContainer/HPBar
@onready var hp_label: Label = $MarginContainer/VBoxContainer/HPBar/HPLabel
@onready var xp_bar: ProgressBar = $MarginContainer/VBoxContainer/XPBar
@onready var level_label: Label = $MarginContainer/VBoxContainer/LevelLabel
@onready var timer_label: Label = $TimerLabel
@onready var wave_label: Label = $WaveLabel

var displayed_hp: float = 100.0
var _wave_mgr: Node = null  # Cached WaveManager reference
var _prev_kills: int = -1
var _prev_level: int = -1

func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.game_over.connect(_on_game_over)
	# Cache WaveManager reference (deferred so scene tree is ready)
	call_deferred("_cache_wave_manager")

func _cache_wave_manager() -> void:
	_wave_mgr = get_tree().current_scene.get_node_or_null("WaveManager")

func _process(_delta: float) -> void:
	var player = GameManager.player
	if player:
		hp_bar.max_value = player.max_hp
		# Smooth HP bar tween
		displayed_hp = lerp(displayed_hp, float(player.current_hp), 0.15)
		hp_bar.value = displayed_hp
		hp_label.text = "HP: %d / %d" % [int(player.current_hp), int(player.max_hp)]

		# Tint bar based on HP ratio
		var ratio = player.current_hp / player.max_hp
		if ratio > 0.5:
			hp_bar.modulate = Color(0.2, 1.0, 0.3)  # Green
		elif ratio > 0.25:
			hp_bar.modulate = Color(1.0, 0.8, 0.0)  # Yellow
		else:
			hp_bar.modulate = Color(1.0, 0.2, 0.2)  # Red

	xp_bar.max_value = GameManager.xp_to_next_level
	xp_bar.value = GameManager.current_xp

	# Only update text labels when values change
	if GameManager.current_level != _prev_level:
		_prev_level = GameManager.current_level
		level_label.text = "Level: %d" % _prev_level

	timer_label.text = GameManager.get_time_string()

	if GameManager.total_kills != _prev_kills:
		_prev_kills = GameManager.total_kills
		kills_label.text = "Kills: %d" % _prev_kills

	# Wave counter (cached reference)
	if _wave_mgr:
		var node_data = ProgressManager.current_node
		if node_data:
			wave_label.text = "Wave %d / %d" % [_wave_mgr.current_wave, node_data.wave_count]
		else:
			wave_label.text = "Wave %d" % _wave_mgr.current_wave
		wave_label.visible = true
	else:
		wave_label.visible = false

func _on_score_changed(new_score: int) -> void:
	score_label.text = "Score: %d" % new_score

func _on_game_over() -> void:
	score_label.text = "GAME OVER — Score: %d" % GameManager.score
