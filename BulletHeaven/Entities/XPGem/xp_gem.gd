extends Area2D

## XPGem.gd
## Dropped by enemies. Flies toward the player when within magnet range.

@export var xp_value: int = 1
@export var magnet_speed: float = 300.0

var is_magnetized: bool = false
var target: Node2D = null

func _ready() -> void:
	add_to_group("XPGem")
	collision_layer = 8
	collision_mask = 1
	area_entered.connect(_on_area_entered)
	
func _physics_process(delta: float) -> void:

	if is_magnetized and target and is_instance_valid(target):
		var dir = (target.global_position - global_position).normalized()
		position += dir * magnet_speed * delta
		
		# If close enough, collect
		if global_position.distance_to(target.global_position) < 10.0:
			_collect()

func _on_area_entered(area: Area2D) -> void:
	# When the player's MagnetArea touches us
	var parent = area.get_parent()
	if parent and parent.is_in_group("Player"):
		is_magnetized = true
		target = parent

func _collect() -> void:
	GameManager.add_xp(xp_value)
	queue_free()
