extends Node

## ProgressManager Autoload
## Tracks world map progress, inventory, and handles save/load.

const SAVE_PATH: String = "user://save_data.json"

signal inventory_changed(item_id: String, new_count: int)
signal region_unlocked(region_id: String)
signal equipment_changed

var completed_nodes: Array = []
var current_node: Resource = null
var unlocked_regions: Array = ["forest"]  # Forest unlocked by default

# Inventory: item_id -> count
var inventory: Dictionary = {}

# Equipment: slot -> item_id (or "" if empty)
var equipped_weapon: String = ""
var equipped_armor: String = ""

# Tracks drops collected during current combat run
var run_loot: Dictionary = {}  # item_id -> count

# Node modifiers selected by the player before entering combat
var active_modifiers: Array[String] = []

# Modifier definitions: id -> { label, description, effect }
const MODIFIER_DEFS: Dictionary = {
	"tough_enemies": {
		"label": "+50% Enemy HP",
		"description": "Enemies have 50% more health",
		"drop_bonus": 0.25,
	},
	"fast_enemies": {
		"label": "+40% Enemy Speed",
		"description": "Enemies move 40% faster",
		"drop_bonus": 0.20,
	},
	"extra_waves": {
		"label": "+2 Waves",
		"description": "Two additional waves of enemies",
		"drop_bonus": 0.30,
	},
	"no_regen": {
		"label": "No HP Regen",
		"description": "HP regeneration is disabled",
		"drop_bonus": 0.15,
	},
}

func get_total_drop_bonus() -> float:
	var bonus: float = 0.0
	for mod_id in active_modifiers:
		if MODIFIER_DEFS.has(mod_id):
			bonus += MODIFIER_DEFS[mod_id]["drop_bonus"]
	return bonus

# Maps boss node_id -> region_id that it unlocks
var boss_unlock_map: Dictionary = {
	"forest_boss": "tundra",
	"tundra_boss": "ruins",
	"ruins_boss": "depths",
	"depths_boss": "nexus",
}

func _ready() -> void:
	load_game()
	debug_fill_materials()  # DEBUG: Remove after testing!

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
	run_loot.clear()
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

# --- Equipment ---

func equip_item(item_id: String) -> bool:
	var item_data = ItemDatabase.get_item(item_id)
	if item_data.is_empty():
		return false
	var item_type = item_data.get("type", "")
	if item_type == "weapon":
		# Unequip current weapon first
		if equipped_weapon != "":
			add_item(equipped_weapon)
		equipped_weapon = item_id
		remove_item(item_id)
		equipment_changed.emit()
		save_game()
		return true
	elif item_type == "armor":
		if equipped_armor != "":
			add_item(equipped_armor)
		equipped_armor = item_id
		remove_item(item_id)
		equipment_changed.emit()
		save_game()
		return true
	return false

func unequip_item(slot: String) -> void:
	if slot == "weapon" and equipped_weapon != "":
		add_item(equipped_weapon)
		equipped_weapon = ""
		equipment_changed.emit()
		save_game()
	elif slot == "armor" and equipped_armor != "":
		add_item(equipped_armor)
		equipped_armor = ""
		equipment_changed.emit()
		save_game()

func get_equipment_stat(stat_name: String) -> float:
	var total: float = 0.0
	if equipped_weapon != "":
		var data = ItemDatabase.get_item(equipped_weapon)
		var stats = data.get("stats", {})
		total += stats.get(stat_name, 0.0)
	if equipped_armor != "":
		var data = ItemDatabase.get_item(equipped_armor)
		var stats = data.get("stats", {})
		total += stats.get(stat_name, 0.0)
	return total

func get_equipped_item_name(slot: String) -> String:
	var item_id = equipped_weapon if slot == "weapon" else equipped_armor
	if item_id == "":
		return "None"
	return ItemDatabase.get_display_name(item_id)

# --- Inventory ---

func add_item(item_id: String, amount: int = 1) -> void:
	if inventory.has(item_id):
		inventory[item_id] += amount
	else:
		inventory[item_id] = amount
	# Track run loot
	if run_loot.has(item_id):
		run_loot[item_id] += amount
	else:
		run_loot[item_id] = amount
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
		"equipped_weapon": equipped_weapon,
		"equipped_armor": equipped_armor,
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
	if err != OK or typeof(json.data) != TYPE_DICTIONARY:
		push_error("ProgressManager: Failed to parse save file or data is invalid.")
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
	equipped_weapon = data.get("equipped_weapon", "")
	equipped_armor = data.get("equipped_armor", "")

func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

func reset() -> void:
	completed_nodes.clear()
	inventory.clear()
	unlocked_regions = ["forest"]
	equipped_weapon = ""
	equipped_armor = ""
	current_node = null
	delete_save()

## DEBUG: Fill all materials to 100 for testing. Remove after testing!
func debug_fill_materials() -> void:
	var material_ids = [
		"wood_shard", "dark_petal", "beast_fang", "ancient_bark", "hollow_core",
		"frost_wisp", "frozen_claw", "yeti_heart",
		"ember_core", "molten_shard", "magma_crystal",
		"void_essence", "shadow_silk", "void_crown",
		"nexus_shard", "rune_fragment", "nexus_core",
	]
	for mat_id in material_ids:
		inventory[mat_id] = 100
	save_game()
	print("DEBUG: All materials set to 100")
