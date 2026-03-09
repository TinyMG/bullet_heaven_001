extends Control

## MinimapDraw
## The drawing surface for the combat minimap.

var map_radius: float = 70.0
var world_range: float = 600.0

func _draw() -> void:
	var center = Vector2(map_radius, map_radius)

	# Background circle
	draw_circle(center, map_radius, Color(0.05, 0.05, 0.15, 0.7))
	# Border
	draw_arc(center, map_radius, 0, TAU, 64, Color(0.4, 0.5, 0.7, 0.8), 1.5)

	# Get player position
	var player = GameManager.player
	if player == null or not is_instance_valid(player):
		return
	var player_pos = player.global_position

	# Draw XP gems (cyan dots, tiny) — draw first so they're behind everything
	var gems = get_tree().get_nodes_in_group("XPGem")
	for gem in gems:
		if not is_instance_valid(gem) or not gem.visible:
			continue
		var offset = gem.global_position - player_pos
		if offset.length() > world_range:
			continue
		var map_pos = center + (offset / world_range) * (map_radius - 4.0)
		if map_pos.distance_to(center) > map_radius - 2.0:
			continue
		draw_circle(map_pos, 1.0, Color(0.2, 0.9, 0.9, 0.5))

	# Draw loot drops (blue dots)
	var drops = get_tree().get_nodes_in_group("LootDrop")
	for drop in drops:
		if not is_instance_valid(drop) or not drop.visible:
			continue
		var offset = drop.global_position - player_pos
		if offset.length() > world_range:
			offset = offset.normalized() * world_range
		var map_pos = center + (offset / world_range) * (map_radius - 4.0)
		if map_pos.distance_to(center) > map_radius - 2.0:
			map_pos = center + (map_pos - center).normalized() * (map_radius - 2.0)
		draw_circle(map_pos, 1.5, Color(0.3, 0.6, 1.0, 0.8))

	# Draw enemies (red dots)
	var enemies = get_tree().get_nodes_in_group("Enemy")
	for enemy in enemies:
		if not is_instance_valid(enemy) or not enemy.visible:
			continue
		var offset = enemy.global_position - player_pos
		var dist = offset.length()
		if dist > world_range:
			offset = offset.normalized() * world_range
		var map_pos = center + (offset / world_range) * (map_radius - 4.0)
		if map_pos.distance_to(center) > map_radius - 2.0:
			map_pos = center + (map_pos - center).normalized() * (map_radius - 2.0)

		var dot_size = 2.0
		var dot_color = Color(1.0, 0.2, 0.2)
		if enemy.is_boss:
			dot_size = 4.0
			dot_color = Color(1.0, 0.8, 0.1)
		draw_circle(map_pos, dot_size, dot_color)

	# Draw player dot (center, green) — always on top
	draw_circle(center, 3.0, Color(0.2, 1.0, 0.4))
