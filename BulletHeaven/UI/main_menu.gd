extends CanvasLayer

@onready var start_button: Button = $Control/VBoxContainer/StartButton
@onready var settings_button: Button = $Control/VBoxContainer/SettingsButton
@onready var quit_button: Button = $Control/VBoxContainer/QuitButton
@onready var settings_panel = $SettingsPanel

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/WorldMap.tscn")

func _on_settings_pressed() -> void:
	settings_panel.show_settings()

func _on_quit_pressed() -> void:
	get_tree().quit()
