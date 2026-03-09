extends Area2D

## LootDrop
## A collectible item that spawns at enemy death position.
## Magnetizes toward player like XP gems.

var item_id: String = ""
var spawn_pos: Vector2 = Vector2.ZERO
var magnet_speed: float = 250.0
var is_magnetized: bool = false
var target: Node2D = null

@onready var sprite: ColorRect = $ColorIndicator
@onready var label: Label = $Label

func setup(id: String, pos: Vector2) -> void:
	item_id = id
	spawn_pos = pos

func _ready() -> void:
	add_to_group("LootDrop")
	collision_layer = 8  # Pickup layer
	collision_mask = 1   # Match XPGem setup exactly
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

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

		if global_position.distance_to(target.global_position) < 15.0:
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
	ProgressManager.add_item(item_id)
	queue_free()
