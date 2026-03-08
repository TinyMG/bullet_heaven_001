extends Node

## AudioManager Autoload
## Handles global sound effects playback. Using an autoload ensures 
## sounds aren't cut off when the entity that played them is destroyed.

@onready var shoot_player: AudioStreamPlayer = $ShootPlayer
@onready var hit_player: AudioStreamPlayer = $HitPlayer
@onready var level_up_player: AudioStreamPlayer = $LevelUpPlayer
@onready var game_over_player: AudioStreamPlayer = $GameOverPlayer

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
