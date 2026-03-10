extends Node2D

## Main.gd
## Root scene: holds the Player, Camera2D (follows player), WaveManager, HUD, and LevelUpPanel.

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera2D

var screen_shake_script = preload("res://Components/screen_shake.gd")

const REGION_TINTS: Dictionary = {
	"forest": Color(0.1, 0.2, 0.1, 0.35),
	"tundra": Color(0.1, 0.15, 0.3, 0.35),
	"ruins": Color(0.25, 0.12, 0.05, 0.35),
	"depths": Color(0.15, 0.05, 0.2, 0.35),
	"nexus": Color(0.25, 0.2, 0.05, 0.35),
}

func _ready() -> void:
	GameManager.reset()
	SkillsManager.reset_all()

	# Attach camera to player so smoothing works natively without script snapping
	if player and camera:
		camera.get_parent().remove_child(camera)
		player.add_child(camera)
		camera.position = Vector2.ZERO

		# Attach screen shake to camera
		var shake_node = Node.new()
		shake_node.name = "ScreenShake"
		shake_node.set_script(screen_shake_script)
		camera.add_child(shake_node)

	_apply_region_tint()

func _apply_region_tint() -> void:
	var node_data = ProgressManager.current_node
	if node_data == null:
		return
	var region: String = node_data.region
	if not REGION_TINTS.has(region):
		return
	# Add a CanvasLayer with a full-screen ColorRect behind gameplay
	var bg_layer = CanvasLayer.new()
	bg_layer.layer = -1
	var tint_rect = ColorRect.new()
	tint_rect.color = REGION_TINTS[region]
	tint_rect.anchors_preset = Control.PRESET_FULL_RECT
	tint_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg_layer.add_child(tint_rect)
	add_child(bg_layer)

