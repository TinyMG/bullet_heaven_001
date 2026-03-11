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
	PlayerStats.reset_run_bonuses()

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
	_start_region_music()
	_spawn_region_particles()

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

func _start_region_music() -> void:
	var node_data = ProgressManager.current_node
	if node_data:
		AudioManager.crossfade_music(node_data.region)
	else:
		AudioManager.play_music("forest")

func _spawn_region_particles() -> void:
	var node_data = ProgressManager.current_node
	if node_data == null or player == null:
		return
	var region: String = node_data.region

	var particles = CPUParticles2D.new()
	particles.emitting = true
	particles.one_shot = false
	particles.local_coords = false

	var fade_gradient = Gradient.new()

	match region:
		"forest":
			particles.amount = 15
			particles.lifetime = 4.0
			particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
			particles.emission_rect_extents = Vector2(300, 10)
			particles.direction = Vector2(0.3, 1)
			particles.spread = 20.0
			particles.gravity = Vector2(0, 30)
			particles.initial_velocity_min = 10.0
			particles.initial_velocity_max = 30.0
			particles.scale_amount_min = 2.0
			particles.scale_amount_max = 4.0
			fade_gradient.set_color(0, Color(0.2, 0.6, 0.1, 0.5))
			fade_gradient.set_color(1, Color(0.5, 0.35, 0.1, 0.0))
		"tundra":
			particles.amount = 30
			particles.lifetime = 5.0
			particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
			particles.emission_rect_extents = Vector2(300, 10)
			particles.direction = Vector2(-0.2, 1)
			particles.spread = 30.0
			particles.gravity = Vector2(0, 20)
			particles.initial_velocity_min = 5.0
			particles.initial_velocity_max = 20.0
			particles.scale_amount_min = 1.0
			particles.scale_amount_max = 3.0
			fade_gradient.set_color(0, Color(0.9, 0.95, 1.0, 0.6))
			fade_gradient.set_color(1, Color(0.9, 0.95, 1.0, 0.0))
		"ruins":
			particles.amount = 20
			particles.lifetime = 3.0
			particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
			particles.emission_rect_extents = Vector2(300, 300)
			particles.direction = Vector2(0, -1)
			particles.spread = 40.0
			particles.gravity = Vector2(0, -10)
			particles.initial_velocity_min = 15.0
			particles.initial_velocity_max = 40.0
			particles.scale_amount_min = 1.0
			particles.scale_amount_max = 3.0
			fade_gradient.set_color(0, Color(1.0, 0.5, 0.1, 0.5))
			fade_gradient.set_color(1, Color(1.0, 0.2, 0.0, 0.0))
		"depths":
			particles.amount = 12
			particles.lifetime = 3.5
			particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
			particles.emission_rect_extents = Vector2(300, 300)
			particles.direction = Vector2(0, 0)
			particles.spread = 180.0
			particles.gravity = Vector2.ZERO
			particles.initial_velocity_min = 5.0
			particles.initial_velocity_max = 15.0
			particles.scale_amount_min = 3.0
			particles.scale_amount_max = 6.0
			fade_gradient.set_color(0, Color(0.3, 0.1, 0.5, 0.3))
			fade_gradient.set_color(1, Color(0.3, 0.1, 0.5, 0.0))
		"nexus":
			particles.amount = 25
			particles.lifetime = 2.0
			particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
			particles.emission_rect_extents = Vector2(300, 300)
			particles.direction = Vector2(0, 0)
			particles.spread = 180.0
			particles.gravity = Vector2.ZERO
			particles.initial_velocity_min = 20.0
			particles.initial_velocity_max = 60.0
			particles.scale_amount_min = 1.0
			particles.scale_amount_max = 2.0
			fade_gradient.set_color(0, Color(1.0, 0.9, 0.3, 0.6))
			fade_gradient.set_color(1, Color(1.0, 0.9, 0.3, 0.0))
		_:
			particles.queue_free()
			return

	particles.color_ramp = fade_gradient
	particles.position = Vector2(0, -100)
	player.add_child(particles)

