extends CanvasLayer

@onready var panel: PanelContainer = $PanelContainer
@onready var resume_button: Button = $PanelContainer/VBoxContainer/ResumeButton
@onready var settings_button: Button = $PanelContainer/VBoxContainer/SettingsButton
@onready var quit_button: Button = $PanelContainer/VBoxContainer/QuitButton
@onready var settings_panel = $SettingsPanel

func _ready() -> void:
	visible = false
	resume_button.pressed.connect(_on_resume_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if not GameManager.is_game_over:
			toggle_pause()

func toggle_pause() -> void:
	var new_pause_state = not get_tree().paused
	get_tree().paused = new_pause_state
	visible = new_pause_state

func _on_resume_pressed() -> void:
	toggle_pause()

func _on_settings_pressed() -> void:
	settings_panel.show_settings()

func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://UI/MainMenu.tscn")
