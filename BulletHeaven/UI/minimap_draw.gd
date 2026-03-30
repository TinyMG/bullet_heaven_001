extends Control

## MinimapDraw
## The drawing surface for the combat minimap.
## Group queries are cached and refreshed on a timer to avoid per-frame overhead.

var map_radius: float = 70.0
var world_range: float = 600.0

# Cached group arrays — refreshed every _update_interval seconds
var _cached_gems: Array = []
var _cached_drops: Array = []
var _cached_enemies: Array = []
var _update_timer: float = 0.0
const _update_interval: float = 0.15  # ~7 updates per second

func _process(delta: float) -> void:
	_update_timer -= delta
	if _update_timer <= 0.0:
		_update_timer = _update_interval
		_cached_gems = get_tree().get_nodes_in_group("XPGem")
		_cached_drops = get_tree().get_nodes_in_group("LootDrop")
		_cached_enemies = get_tree().get_nodes_in_group("Enemy")
	queue_redraw()

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
	var inv_range = 1.0 / world_range
	var draw_radius = map_radius - 4.0
	var clip_radius = map_radius - 2.0

	# Draw XP gems (cyan dots, tiny) — draw first so they're behind everything
	var world_range_sq = world_range * world_range
	var clip_radius_sq = clip_radius * clip_radius
	for gem in _cached_gems:
		if not is_instance_valid(gem) or not gem.visible:
			continue
		var offset = gem.global_position - player_pos
		if offset.length_squared() > world_range_sq:
			continue
		var map_pos = center + offset * inv_range * draw_radius
		if map_pos.distance_squared_to(center) > clip_radius_sq:
			continue
		draw_circle(map_pos, 1.0, Color(0.2, 0.9, 0.9, 0.5))

	# Draw loot drops (blue dots)
	for drop in _cached_drops:
		if not is_instance_valid(drop) or not drop.visible:
			continue
		var offset = drop.global_position - player_pos
		if offset.length_squared() > world_range_sq:
			offset = offset.normalized() * world_range
		var map_pos = center + offset * inv_range * draw_radius
		if map_pos.distance_squared_to(center) > clip_radius_sq:
			map_pos = center + (map_pos - center).normalized() * clip_radius
		draw_circle(map_pos, 1.5, Color(0.3, 0.6, 1.0, 0.8))

	# Draw enemies (red dots)
	for enemy in _cached_enemies:
		if not is_instance_valid(enemy) or not enemy.visible:
			continue
		var offset = enemy.global_position - player_pos
		if offset.length_squared() > world_range_sq:
			offset = offset.normalized() * world_range
		var map_pos = center + offset * inv_range * draw_radius
		if map_pos.distance_squared_to(center) > clip_radius_sq:
			map_pos = center + (map_pos - center).normalized() * clip_radius

		var dot_size = 2.0
		var dot_color = Color(1.0, 0.2, 0.2)
		if enemy.is_boss:
			dot_size = 4.0
			dot_color = Color(1.0, 0.8, 0.1)
		draw_circle(map_pos, dot_size, dot_color)

	# Draw player dot (center, green) — always on top
	draw_circle(center, 3.0, Color(0.2, 1.0, 0.4))
