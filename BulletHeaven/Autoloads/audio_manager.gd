extends Node

## AudioManager Autoload
## Handles global sound effects and music playback. Using an autoload ensures
## sounds aren't cut off when the entity that played them is destroyed.

@onready var shoot_player: AudioStreamPlayer = $ShootPlayer
@onready var hit_player: AudioStreamPlayer = $HitPlayer
@onready var level_up_player: AudioStreamPlayer = $LevelUpPlayer
@onready var game_over_player: AudioStreamPlayer = $GameOverPlayer
@onready var music_player: AudioStreamPlayer = $MusicPlayer

var _current_music_key: String = ""

func play_shoot() -> void:
	# Randomize pitch slightly for variety
	shoot_player.pitch_scale = randf_range(0.9, 1.1)
	shoot_player.play()

func play_hit() -> void:
	hit_player.pitch_scale = randf_range(0.8, 1.2)
	hit_player.play()

func play_level_up() -> void:
	level_up_player.play()

func play_game_over() -> void:
	game_over_player.play()

func play_music(region_key: String) -> void:
	if region_key == _current_music_key and music_player.playing:
		return
	var path = "res://assets/audio/music/%s_theme.ogg" % region_key
	if not ResourceLoader.exists(path):
		return
	_current_music_key = region_key
	music_player.stream = load(path)
	music_player.play()

func stop_music() -> void:
	music_player.stop()
	_current_music_key = ""

func crossfade_music(region_key: String, duration: float = 1.0) -> void:
	if region_key == _current_music_key and music_player.playing:
		return
	var path = "res://assets/audio/music/%s_theme.ogg" % region_key
	if not ResourceLoader.exists(path):
		return
	if music_player.playing:
		var original_db = music_player.volume_db
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -40.0, duration * 0.5)
		tween.tween_callback(func():
			_current_music_key = region_key
			music_player.stream = load(path)
			music_player.play()
			music_player.volume_db = -40.0
		)
		tween.tween_property(music_player, "volume_db", original_db, duration * 0.5)
	else:
		play_music(region_key)
