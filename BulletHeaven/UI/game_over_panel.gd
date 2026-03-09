extends CanvasLayer

@onready var panel: PanelContainer = $PanelContainer
@onready var score_label: Label = $PanelContainer/VBoxContainer/ScoreLabel
@onready var time_label: Label = $PanelContainer/VBoxContainer/TimeLabel
@onready var kills_label: Label = $PanelContainer/VBoxContainer/KillsLabel
@onready var damage_label: Label = $PanelContainer/VBoxContainer/DamageLabel
@onready var restart_button: Button = $PanelContainer/VBoxContainer/RestartButton
@onready var quit_button: Button = $PanelContainer/VBoxContainer/QuitButton

func _ready() -> void:
	visible = false
	GameManager.game_over.connect(_on_game_over)
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_game_over() -> void:
	score_label.text = "Final Score: %d" % GameManager.score
	time_label.text = "Time Survived: %s" % GameManager.get_time_string()
	kills_label.text = "Enemies Killed: %d" % GameManager.total_kills
	damage_label.text = "Damage Dealt: %d" % int(GameManager.total_damage_dealt)
	visible = true
	get_tree().paused = true
	AudioManager.play_game_over()

func _on_restart_pressed() -> void:
	get_tree().paused = false
	ObjectPool.clear_all()
	GameManager.reset()
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().paused = false
	ObjectPool.clear_all()
	get_tree().change_scene_to_file("res://UI/WorldMap.tscn")
