extends CanvasLayer

@onready var panel: PanelContainer = $PanelContainer
@onready var score_label: Label = $PanelContainer/VBoxContainer/ScoreLabel
@onready var restart_button: Button = $PanelContainer/VBoxContainer/RestartButton

func _ready() -> void:
	visible = false
	GameManager.game_over.connect(_on_game_over)
	restart_button.pressed.connect(_on_restart_pressed)

func _on_game_over() -> void:
	score_label.text = "Final Score: %d" % GameManager.score
	visible = true
	get_tree().paused = true
	AudioManager.play_game_over()

func _on_restart_pressed() -> void:
	get_tree().paused = false
	GameManager.reset()
	get_tree().reload_current_scene()
