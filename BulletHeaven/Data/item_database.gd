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
	# Tundra materials
	"frost_wisp": {
		"display_name": "Frost Wisp",
		"description": "A shimmering ice fragment from a wraith.",
		"type": "material",
		"rarity": "common",
		"icon_color": Color(0.6, 0.85, 1.0),
	},
	"frozen_claw": {
		"display_name": "Frozen Claw",
		"description": "A crystallized claw from a frost bear.",
		"type": "material",
		"rarity": "uncommon",
		"icon_color": Color(0.4, 0.7, 0.9),
	},
	"yeti_heart": {
		"display_name": "Yeti Heart",
		"description": "A still-beating frozen heart from the Yeti boss.",
		"type": "material",
		"rarity": "epic",
		"icon_color": Color(0.3, 0.5, 1.0),
	},
	# Ruins materials (Region 3)
	"ember_core": {
		"display_name": "Ember Core",
		"description": "A smoldering fragment from a fire elemental.",
		"type": "material",
		"rarity": "common",
		"icon_color": Color(1.0, 0.5, 0.1),
	},
	"molten_shard": {
		"display_name": "Molten Shard",
		"description": "A glowing shard of cooled magma.",
		"type": "material",
		"rarity": "uncommon",
		"icon_color": Color(0.9, 0.3, 0.1),
	},
	"magma_crystal": {
		"display_name": "Magma Crystal",
		"description": "A crystallized core from the Magma Golem boss.",
		"type": "material",
		"rarity": "epic",
		"icon_color": Color(1.0, 0.2, 0.0),
	},
	# Depths materials (Region 4)
	"void_essence": {
		"display_name": "Void Essence",
		"description": "A wisp of shadow energy from a stalker.",
		"type": "material",
		"rarity": "common",
		"icon_color": Color(0.3, 0.1, 0.5),
	},
	"shadow_silk": {
		"display_name": "Shadow Silk",
		"description": "Thread-like darkness woven from the void.",
		"type": "material",
		"rarity": "uncommon",
		"icon_color": Color(0.2, 0.05, 0.3),
	},
	"void_crown": {
		"display_name": "Void Crown",
		"description": "A dark relic from the Void Lord boss.",
		"type": "material",
		"rarity": "epic",
		"icon_color": Color(0.5, 0.0, 0.8),
	},
	# Nexus materials (Region 5)
	"rune_fragment": {
		"display_name": "Rune Fragment",
		"description": "A shard of raw runic energy.",
		"type": "material",
		"rarity": "uncommon",
		"icon_color": Color(0.9, 0.8, 0.2),
	},
	"nexus_core": {
		"display_name": "Nexus Core",
		"description": "The pulsing heart of the Rune Nexus guardian.",
		"type": "material",
		"rarity": "epic",
		"icon_color": Color(1.0, 0.9, 0.3),
	},
	# Weapons
	"iron_fang_blade": {
		"display_name": "Iron Fang Blade",
		"description": "A crude blade forged from beast fangs. Cuts deep.",
		"type": "weapon",
		"rarity": "uncommon",
		"icon_color": Color(0.7, 0.7, 0.7),
		"stats": {"damage": 8.0, "fire_rate": 0.05},
		"weapon_type": "standard",
	},
	"frost_bow": {
		"display_name": "Frost Bow",
		"description": "A bow that fires a wide spread of icy bolts.",
		"type": "weapon",
		"rarity": "rare",
		"icon_color": Color(0.5, 0.8, 1.0),
		"stats": {"damage": 12.0, "projectile_count": 1},
		"weapon_type": "spread",
	},
	# Armor
	"slime_shield": {
		"display_name": "Slime Shield",
		"description": "A sticky shield that absorbs hits surprisingly well.",
		"type": "armor",
		"rarity": "uncommon",
		"icon_color": Color(0.3, 0.8, 0.3),
		"stats": {"max_hp": 25.0, "hp_regen": 0.5},
	},
	"frozen_mail": {
		"display_name": "Frozen Mail",
		"description": "Armor forged from glacial shards. Cold to the touch.",
		"type": "armor",
		"rarity": "rare",
		"icon_color": Color(0.6, 0.85, 1.0),
		"stats": {"max_hp": 40.0, "move_speed": 10.0},
	},
	"ember_blade": {
		"display_name": "Ember Blade",
		"description": "A sword wreathed in flame. Projectiles seek out enemies.",
		"type": "weapon",
		"rarity": "rare",
		"icon_color": Color(1.0, 0.4, 0.1),
		"stats": {"damage": 18.0, "fire_rate": 0.08},
		"weapon_type": "homing",
	},
	"magma_plate": {
		"display_name": "Magma Plate",
		"description": "Volcanic armor that radiates heat.",
		"type": "armor",
		"rarity": "rare",
		"icon_color": Color(0.9, 0.3, 0.1),
		"stats": {"max_hp": 60.0, "hp_regen": 1.5},
	},
	"void_scythe": {
		"display_name": "Void Scythe",
		"description": "A blade forged from pure darkness. Cuts through all enemies.",
		"type": "weapon",
		"rarity": "epic",
		"icon_color": Color(0.4, 0.0, 0.7),
		"stats": {"damage": 25.0, "projectile_pierce": 2},
		"weapon_type": "piercing",
	},
	"void_mantle": {
		"display_name": "Void Mantle",
		"description": "A cloak woven from shadow. Makes you nearly untouchable.",
		"type": "armor",
		"rarity": "epic",
		"icon_color": Color(0.3, 0.05, 0.5),
		"stats": {"max_hp": 80.0, "move_speed": 25.0, "hp_regen": 2.0},
	},
	"nexus_cannon": {
		"display_name": "Nexus Cannon",
		"description": "The ultimate weapon. Projectiles explode on impact.",
		"type": "weapon",
		"rarity": "epic",
		"icon_color": Color(1.0, 0.9, 0.2),
		"stats": {"damage": 30.0, "projectile_count": 2, "fire_rate": 0.1},
		"weapon_type": "aoe",
	},
	"nexus_aegis": {
		"display_name": "Nexus Aegis",
		"description": "The ultimate shield. Imbued with the power of all runes.",
		"type": "armor",
		"rarity": "epic",
		"icon_color": Color(1.0, 0.85, 0.3),
		"stats": {"max_hp": 100.0, "hp_regen": 3.0, "move_speed": 15.0},
	},
	# Runes (craftable key items)
	"forest_rune": {
		"display_name": "Forest Rune",
		"description": "A rune carved from forest materials. Used to unlock paths.",
		"type": "rune",
		"rarity": "rare",
		"icon_color": Color(0.2, 0.8, 0.4),
	},
	"rune_of_the_wild": {
		"display_name": "Rune of the Wild",
		"description": "A powerful rune forged from the forest guardian's essence. Unlocks the Frostpeak Tundra.",
		"type": "rune",
		"rarity": "epic",
		"icon_color": Color(0.1, 0.9, 0.3),
	},
	"tundra_rune": {
		"display_name": "Tundra Rune",
		"description": "A rune infused with frost energy. Used to unlock tundra paths.",
		"type": "rune",
		"rarity": "rare",
		"icon_color": Color(0.5, 0.8, 1.0),
	},
	"rune_of_the_glacier": {
		"display_name": "Rune of the Glacier",
		"description": "Forged from the Yeti's heart. Unlocks the Emberveil Ruins.",
		"type": "rune",
		"rarity": "epic",
		"icon_color": Color(0.3, 0.6, 1.0),
	},
	"ruins_rune": {
		"display_name": "Ruins Rune",
		"description": "A rune pulsing with ember energy. Unlocks ruins paths.",
		"type": "rune",
		"rarity": "rare",
		"icon_color": Color(1.0, 0.5, 0.2),
	},
	"rune_of_embers": {
		"display_name": "Rune of Embers",
		"description": "Forged from magma crystal. Unlocks the Shadow Depths.",
		"type": "rune",
		"rarity": "epic",
		"icon_color": Color(1.0, 0.3, 0.0),
	},
	"depths_rune": {
		"display_name": "Depths Rune",
		"description": "A rune touched by the void. Unlocks depths paths.",
		"type": "rune",
		"rarity": "rare",
		"icon_color": Color(0.4, 0.1, 0.6),
	},
	"rune_of_shadows": {
		"display_name": "Rune of Shadows",
		"description": "Forged from the void crown. Unlocks The Rune Nexus.",
		"type": "rune",
		"rarity": "epic",
		"icon_color": Color(0.5, 0.0, 0.9),
	},
	"nexus_rune": {
		"display_name": "Nexus Rune",
		"description": "A rune of pure energy. Unlocks nexus paths.",
		"type": "rune",
		"rarity": "rare",
		"icon_color": Color(1.0, 0.9, 0.3),
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
