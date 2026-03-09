extends Node

## ItemDatabase
## Central registry of all item definitions. Access via ItemDatabase.get_item("id").

# item_id -> { display_name, description, type, rarity, icon_color }
# type: "material", "rune", "consumable"
# rarity: "common", "uncommon", "rare", "epic"

var items: Dictionary = {
	# Forest materials
	"wood_shard": {
		"display_name": "Wood Shard",
		"description": "A splintered piece of enchanted wood.",
		"type": "material",
		"rarity": "common",
		"icon_color": Color(0.6, 0.4, 0.2),
	},
	"dark_petal": {
		"display_name": "Dark Petal",
		"description": "A petal from the forest's shadowy flowers.",
		"type": "material",
		"rarity": "common",
		"icon_color": Color(0.5, 0.2, 0.6),
	},
	"beast_fang": {
		"display_name": "Beast Fang",
		"description": "A sharp fang from a forest creature.",
		"type": "material",
		"rarity": "uncommon",
		"icon_color": Color(0.9, 0.9, 0.8),
	},
	"ancient_bark": {
		"display_name": "Ancient Bark",
		"description": "Petrified bark from the forest guardian.",
		"type": "material",
		"rarity": "rare",
		"icon_color": Color(0.3, 0.6, 0.3),
	},
	"hollow_core": {
		"display_name": "Hollow Core",
		"description": "A pulsing orb dropped by the Ancient Hollow boss.",
		"type": "material",
		"rarity": "epic",
		"icon_color": Color(1.0, 0.4, 0.8),
	},
	# Runes (craftable key items)
	"forest_rune": {
		"display_name": "Forest Rune",
		"description": "A rune carved from forest materials. Used to unlock paths.",
		"type": "rune",
		"rarity": "rare",
		"icon_color": Color(0.2, 0.8, 0.4),
	},
}

func get_item(item_id: String) -> Dictionary:
	if items.has(item_id):
		return items[item_id]
	return {}

func get_display_name(item_id: String) -> String:
	var item = get_item(item_id)
	return item.get("display_name", item_id)

func get_rarity_color(rarity: String) -> Color:
	match rarity:
		"common": return Color(0.8, 0.8, 0.8)
		"uncommon": return Color(0.3, 0.9, 0.3)
		"rare": return Color(0.3, 0.5, 1.0)
		"epic": return Color(0.8, 0.3, 1.0)
	return Color.WHITE
