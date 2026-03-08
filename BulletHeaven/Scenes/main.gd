extends Node2D

## Main.gd
## Root scene: holds the Player, Camera2D (follows player), WaveManager, HUD, and LevelUpPanel.

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	GameManager.reset()
	SkillsManager.reset_all()

	# Attach camera to player so smoothing works natively without script snapping
	if player and camera:
		camera.get_parent().remove_child(camera)
		player.add_child(camera)
		camera.position = Vector2.ZERO
