extends Area2D

## LootDrop
## A collectible item that spawns at enemy death position.
## Magnetizes toward player like XP gems. Supports object pooling.

var item_id: String = ""
var spawn_pos: Vector2 = Vector2.ZERO
var magnet_speed: float = 250.0
var is_magnetized: bool = false
var target: Node2D = null
var _ready_done: bool = false

@onready var sprite: ColorRect = $ColorIndicator
@onready var label: Label = $Label

func setup(id: String, pos: Vector2) -> void:
	item_id = id
	spawn_pos = pos

func _ready() -> void:
	if not _ready_done:
		add_to_group("LootDrop")
		collision_layer = 8  # Pickup layer
		collision_mask = 1   # Match XPGem setup exactly
		area_entered.connect(_on_area_entered)
		body_entered.connect(_on_body_entered)
		_ready_done = true
	_apply_setup()

func activate() -> void:
	_apply_setup()

func _apply_setup() -> void:
	# Reset state
	is_magnetized = false
	target = null
	visible = true
	set_physics_process(true)
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)

	# Apply position from setup
	global_position = spawn_pos

	# Color the indicator based on item data
	var item_data = ItemDatabase.get_item(item_id)
	if not item_data.is_empty():
		sprite.color = item_data.get("icon_color", Color.WHITE)
		label.text = item_data.get("display_name", item_id)
	else:
		label.text = item_id

	# Brief pop-in animation
	scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _physics_process(delta: float) -> void:
	if is_magnetized and target and is_instance_valid(target):
		var dir = (target.global_position - global_position).normalized()
		position += dir * magnet_speed * delta

		if global_position.distance_squared_to(target.global_position) < 225.0:
			_collect()

	# Bob up and down
	sprite.position.y = sin(Time.get_ticks_msec() * 0.005) * 3.0

func _on_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent and parent.is_in_group("Player"):
		is_magnetized = true
		target = parent

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_magnetized = true
		target = body

func _collect() -> void:
	_spawn_pickup_text()
	ProgressManager.add_item(item_id)
	_release()

func _spawn_pickup_text() -> void:
	var item_data = ItemDatabase.get_item(item_id)
	var display_name = item_data.get("display_name", item_id)
	var rarity = item_data.get("rarity", "common")
	var color = ItemDatabase.get_rarity_color(rarity)

	var float_label = Label.new()
	float_label.text = "+%s" % display_name
	float_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	float_label.add_theme_font_size_override("font_size", 14)
	float_label.add_theme_color_override("font_color", color)
	float_label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	float_label.add_theme_constant_override("outline_size", 2)
	float_label.global_position = global_position + Vector2(-40, -20)
	float_label.z_index = 100
	get_tree().current_scene.add_child(float_label)

	var tween = float_label.create_tween()
	tween.set_parallel(true)
	tween.tween_property(float_label, "position:y", float_label.position.y - 40, 0.9).set_ease(Tween.EASE_OUT)
	tween.tween_property(float_label, "modulate:a", 0.0, 0.9).set_delay(0.3)
	tween.chain().tween_callback(float_label.queue_free)

func _release() -> void:
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	set_physics_process(false)
	visible = false
	ObjectPool.release_node.call_deferred(self)
