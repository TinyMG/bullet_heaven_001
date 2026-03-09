extends Node

## ProgressManager Autoload
## Tracks world map progress, inventory, and handles save/load.

const SAVE_PATH: String = "user://save_data.json"

signal inventory_changed(item_id: String, new_count: int)
signal region_unlocked(region_id: String)

var completed_nodes: Array = []
var current_node: Resource = null
var unlocked_regions: Array = ["forest"]  # Forest unlocked by default

# Inventory: item_id -> count
var inventory: Dictionary = {}

# Maps boss node_id -> region_id that it unlocks
var boss_unlock_map: Dictionary = {
	"forest_boss": "tundra",
	"tundra_boss": "ruins",
	"ruins_boss": "depths",
	"depths_boss": "nexus",
}

func _ready() -> void:
	load_game()

# --- Map Progress ---

func is_node_unlocked(node_data: Resource) -> bool:
	for req in node_data.unlock_requires:
		if req not in completed_nodes:
			return false
	# Check rune requirement
	var rune_req: String = node_data.get("rune_required")
	if rune_req != null and rune_req != "":
		if not has_item(rune_req):
			return false
	return true

func use_rune_for_node(node_data: Resource) -> bool:
	var rune_req: String = node_data.get("rune_required")
	if rune_req == null or rune_req == "":
		return true
	return remove_item(rune_req)

func is_node_completed(node_id: String) -> bool:
	return node_id in completed_nodes

func select_node(node_data: Resource) -> void:
	current_node = node_data
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")

func complete_node(node_id: String) -> void:
	if node_id not in completed_nodes:
		completed_nodes.append(node_id)
	# Check if this boss unlocks a new region
	if boss_unlock_map.has(node_id):
		var new_region = boss_unlock_map[node_id]
		if new_region not in unlocked_regions:
			unlock_region(new_region)
	save_game()

func unlock_region(region_id: String) -> void:
	if region_id not in unlocked_regions:
		unlocked_regions.append(region_id)
		region_unlocked.emit(region_id)

func is_region_unlocked(region_id: String) -> bool:
	return region_id in unlocked_regions

# --- Inventory ---

func add_item(item_id: String, amount: int = 1) -> void:
	if inventory.has(item_id):
		inventory[item_id] += amount
	else:
		inventory[item_id] = amount
	inventory_changed.emit(item_id, inventory[item_id])

func remove_item(item_id: String, amount: int = 1) -> bool:
	if not inventory.has(item_id) or inventory[item_id] < amount:
		return false
	inventory[item_id] -= amount
	if inventory[item_id] <= 0:
		inventory.erase(item_id)
		inventory_changed.emit(item_id, 0)
	else:
		inventory_changed.emit(item_id, inventory[item_id])
	return true

func get_item_count(item_id: String) -> int:
	return inventory.get(item_id, 0)

func has_item(item_id: String, amount: int = 1) -> bool:
	return get_item_count(item_id) >= amount

# --- Save / Load ---

func save_game() -> void:
	var data: Dictionary = {
		"completed_nodes": completed_nodes,
		"inventory": inventory,
		"unlocked_regions": unlocked_regions,
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("ProgressManager: Failed to open save file for writing.")
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("ProgressManager: Failed to open save file for reading.")
		return
	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var err = json.parse(json_text)
	if err != OK:
		push_error("ProgressManager: Failed to parse save file.")
		return

	var data: Dictionary = json.data
	if data.has("completed_nodes"):
		completed_nodes = Array(data["completed_nodes"])
	if data.has("inventory"):
		inventory = data["inventory"]
	if data.has("unlocked_regions"):
		unlocked_regions = Array(data["unlocked_regions"])
	else:
		unlocked_regions = ["forest"]

func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

func reset() -> void:
	completed_nodes.clear()
	inventory.clear()
	unlocked_regions = ["forest"]
	current_node = null
	delete_save()
