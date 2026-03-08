extends CanvasLayer

## HUD.gd
## Displays score, HP bar, XP bar, and level indicator.

@onready var score_label: Label = $MarginContainer/VBoxContainer/ScoreLabel
@onready var hp_bar: ProgressBar = $MarginContainer/VBoxContainer/HPBar
@onready var xp_bar: ProgressBar = $MarginContainer/VBoxContainer/XPBar
@onready var level_label: Label = $MarginContainer/VBoxContainer/LevelLabel

func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.game_over.connect(_on_game_over)

func _process(_delta: float) -> void:
	var player = GameManager.player
	if player:
		hp_bar.max_value = player.max_hp
		hp_bar.value = player.current_hp
	
	xp_bar.max_value = GameManager.xp_to_next_level
	xp_bar.value = GameManager.current_xp
	level_label.text = "Level: %d" % GameManager.current_level

func _on_score_changed(new_score: int) -> void:
	score_label.text = "Score: %d" % new_score

func _on_game_over() -> void:
	score_label.text = "GAME OVER — Score: %d" % GameManager.score
