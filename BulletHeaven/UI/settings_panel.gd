extends CanvasLayer

## SettingsPanel
## Volume sliders for SFX and Music. Persists settings to save file.

const SETTINGS_PATH: String = "user://settings.json"

@onready var panel: PanelContainer = $PanelContainer
@onready var sfx_slider: HSlider = $PanelContainer/VBoxContainer/SFXRow/SFXSlider
@onready var sfx_value: Label = $PanelContainer/VBoxContainer/SFXRow/SFXValue
@onready var music_slider: HSlider = $PanelContainer/VBoxContainer/MusicRow/MusicSlider
@onready var music_value: Label = $PanelContainer/VBoxContainer/MusicRow/MusicValue
@onready var close_button: Button = $PanelContainer/VBoxContainer/CloseButton

var sfx_volume: float = 1.0
var music_volume: float = 1.0

func _ready() -> void:
	visible = false
	close_button.pressed.connect(_on_close_pressed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	music_slider.value_changed.connect(_on_music_changed)
	_load_settings()

func show_settings() -> void:
	sfx_slider.value = sfx_volume * 100.0
	music_slider.value = music_volume * 100.0
	_update_labels()
	visible = true

func _on_sfx_changed(value: float) -> void:
	sfx_volume = value / 100.0
	_update_labels()
	_apply_volumes()

func _on_music_changed(value: float) -> void:
	music_volume = value / 100.0
	_update_labels()
	_apply_volumes()

func _update_labels() -> void:
	sfx_value.text = "%d%%" % int(sfx_volume * 100)
	music_value.text = "%d%%" % int(music_volume * 100)

func _apply_volumes() -> void:
	# SFX bus
	var sfx_bus = AudioServer.get_bus_index("SFX")
	if sfx_bus >= 0:
		var sfx_db = linear_to_db(sfx_volume) if sfx_volume > 0.0 else -80.0
		AudioServer.set_bus_volume_db(sfx_bus, sfx_db)
		AudioServer.set_bus_mute(sfx_bus, sfx_volume <= 0.0)
	# Music bus
	var music_bus = AudioServer.get_bus_index("Music")
	if music_bus >= 0:
		var music_db = linear_to_db(music_volume) if music_volume > 0.0 else -80.0
		AudioServer.set_bus_volume_db(music_bus, music_db)
		AudioServer.set_bus_mute(music_bus, music_volume <= 0.0)

func _on_close_pressed() -> void:
	_save_settings()
	visible = false

func _save_settings() -> void:
	var data = {
		"sfx_volume": sfx_volume,
		"music_volume": music_volume,
	}
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()

func _load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file == null:
		return
	var json = JSON.new()
	var err = json.parse(file.get_as_text())
	file.close()
	if err != OK:
		return

	# SENTINEL: Type-check JSON data to prevent runtime crash from malformed settings
	if typeof(json.data) != TYPE_DICTIONARY:
		return

	var data: Dictionary = json.data
	sfx_volume = data.get("sfx_volume", 1.0)
	music_volume = data.get("music_volume", 1.0)
	_apply_volumes()
