extends Node

## ItemDatabase
## Central registry of all item definitions. Access via ItemDatabase.get_item("id").

# item_id -> { display_name, description, type, rarity, icon_color, ... }
# type: "material", "weapon", "armor", "rune", "consumable"
# rarity: "common", "uncommon", "rare", "epic"
# Materials have "region" (int 1-5)
# Weapons/armor get "star_tier" (int 1-5) computed from recipes at startup

# Tier stat multipliers: index 0 unused, 1-5 = tier 1-5
const TIER_MULTIPLIERS: Array[float] = [1.0, 1.0, 1.25, 1.60, 2.10, 2.75]

var items: Dictionary = {
	# ── Region 1: Forest Materials ──
	"wood_shard": {
		"display_name": "Wood Shard",
		"description": "A splintered piece of enchanted wood.",
		"type": "material",
		"rarity": "common",
		"icon_color": Color(0.6, 0.4, 0.2),
		"region": 1,
	},
	"dark_petal": {
		"display_name": "Dark Petal",
		"description": "A petal from the forest's shadowy flowers.",
		"type": "material",
		"rarity": "common",
		"icon_color": Color(0.5, 0.2, 0.6),
		"region": 1,
	},
	"beast_fang": {
		"display_name": "Beast Fang",
		"description": "A sharp fang from a forest creature.",
		"type": "material",
		"rarity": "uncommon",
		"icon_color": Color(0.9, 0.9, 0.8),
		"region": 1,
	},
	"ancient_bark": {
		"display_name": "Ancient Bark",
		"description": "Petrified bark from the forest guardian.",
		"type": "material",
		"rarity": "rare",
		"icon_color": Color(0.3, 0.6, 0.3),
		"region": 1,
	},
	"hollow_core": {
		"display_name": "Hollow Core",
		"description": "A pulsing orb dropped by the Ancient Hollow boss.",
		"type": "material",
		"rarity": "epic",
		"icon_color": Color(1.0, 0.4, 0.8),
		"region": 1,
	},
	# ── Region 2: Tundra Materials ──
	"frost_wisp": {
		"display_name": "Frost Wisp",
		"description": "A shimmering ice fragment from a wraith.",
		"type": "material",
		"rarity": "common",
		"icon_color": Color(0.6, 0.85, 1.0),
		"region": 2,
	},
	"frozen_claw": {
		"display_name": "Frozen Claw",
		"description": "A crystallized claw from a frost bear.",
		"type": "material",
		"rarity": "uncommon",
		"icon_color": Color(0.4, 0.7, 0.9),
		"region": 2,
	},
	"yeti_heart": {
		"display_name": "Yeti Heart",
		"description": "A still-beating frozen heart from the Yeti boss.",
		"type": "material",
		"rarity": "epic",
		"icon_color": Color(0.3, 0.5, 1.0),
		"region": 2,
	},
	# ── Region 3: Ruins Materials ──
	"ember_core": {
		"display_name": "Ember Core",
		"description": "A smoldering fragment from a fire elemental.",
		"type": "material",
		"rarity": "common",
		"icon_color": Color(1.0, 0.5, 0.1),
		"region": 3,
	},
	"molten_shard": {
		"display_name": "Molten Shard",
		"description": "A glowing shard of cooled magma.",
		"type": "material",
		"rarity": "uncommon",
		"icon_color": Color(0.9, 0.3, 0.1),
		"region": 3,
	},
	"magma_crystal": {
		"display_name": "Magma Crystal",
		"description": "A crystallized core from the Magma Golem boss.",
		"type": "material",
		"rarity": "epic",
		"icon_color": Color(1.0, 0.2, 0.0),
		"region": 3,
	},
	# ── Region 4: Depths Materials ──
	"void_essence": {
		"display_name": "Void Essence",
		"description": "A wisp of shadow energy from a stalker.",
		"type": "material",
		"rarity": "common",
		"icon_color": Color(0.3, 0.1, 0.5),
		"region": 4,
	},
	"shadow_silk": {
		"display_name": "Shadow Silk",
		"description": "Thread-like darkness woven from the void.",
		"type": "material",
		"rarity": "uncommon",
		"icon_color": Color(0.2, 0.05, 0.3),
		"region": 4,
	},
	"void_crown": {
		"display_name": "Void Crown",
		"description": "A dark relic from the Void Lord boss.",
		"type": "material",
		"rarity": "epic",
		"icon_color": Color(0.5, 0.0, 0.8),
		"region": 4,
	},
	# ── Region 5: Nexus Materials ──
	"nexus_shard": {
		"display_name": "Nexus Shard",
		"description": "A crystalline fragment of nexus energy.",
		"type": "material",
		"rarity": "uncommon",
		"icon_color": Color(0.8, 0.7, 1.0),
		"region": 5,
	},
	"rune_fragment": {
		"display_name": "Rune Fragment",
		"description": "A shard of raw runic energy.",
		"type": "material",
		"rarity": "uncommon",
		"icon_color": Color(0.9, 0.8, 0.2),
		"region": 5,
	},
	"nexus_core": {
		"display_name": "Nexus Core",
		"description": "The pulsing heart of the Rune Nexus guardian.",
		"type": "material",
		"rarity": "epic",
		"icon_color": Color(1.0, 0.9, 0.3),
		"region": 5,
	},

	# ══════════════════════════════════════
	# WEAPONS — Fang Blade Chain (standard)
	# ══════════════════════════════════════
	"iron_fang_blade": {
		"display_name": "Iron Fang Blade",
		"description": "A crude blade forged from beast fangs. Cuts deep.",
		"type": "weapon",
		"rarity": "uncommon",
		"icon_color": Color(0.7, 0.7, 0.7),
		"stats": {"damage": 8.0, "fire_rate": 0.05, "power_bonus": 12, "attack_speed_base": 1.2},
		"weapon_type": "standard",
	},
	"steel_fang_blade": {
		"display_name": "Steel Fang Blade",
		"description": "A refined blade tempered in frost. Stronger than iron.",
		"type": "weapon",
		"rarity": "rare",
		"icon_color": Color(0.5, 0.7, 0.9),
		"stats": {"damage": 8.0, "fire_rate": 0.05, "power_bonus": 12, "attack_speed_base": 1.2},
		"weapon_type": "standard",
	},
	"runed_fang_blade": {
		"display_name": "Runed Fang Blade",
		"description": "Ember runes etched into the blade amplify its strike.",
		"type": "weapon",
		"rarity": "rare",
		"icon_color": Color(1.0, 0.5, 0.2),
		"stats": {"damage": 8.0, "fire_rate": 0.05, "power_bonus": 12, "attack_speed_base": 1.2},
		"weapon_type": "standard",
	},
	"void_fang_blade": {
		"display_name": "Void Fang Blade",
		"description": "Darkness clings to every edge. Cuts through reality.",
		"type": "weapon",
		"rarity": "epic",
		"icon_color": Color(0.4, 0.1, 0.6),
		"stats": {"damage": 8.0, "fire_rate": 0.05, "power_bonus": 12, "attack_speed_base": 1.2},
		"weapon_type": "standard",
	},
	"nexus_fang_blade": {
		"display_name": "Nexus Fang Blade",
		"description": "The ultimate fang blade. Channels the power of all regions.",
		"type": "weapon",
		"rarity": "epic",
		"icon_color": Color(1.0, 0.85, 0.3),
		"stats": {"damage": 8.0, "fire_rate": 0.05, "power_bonus": 12, "attack_speed_base": 1.2},
		"weapon_type": "standard",
	},

	# ══════════════════════════════════════
	# WEAPONS — Bow Chain (spread)
	# ══════════════════════════════════════
	"frost_bow": {
		"display_name": "Frost Bow",
		"description": "A bow that fires a wide spread of icy bolts.",
		"type": "weapon",
		"rarity": "rare",
		"icon_color": Color(0.5, 0.8, 1.0),
		"stats": {"damage": 12.0, "projectile_count": 1, "power_bonus": 8, "attack_speed_base": 1.5},
		"weapon_type": "spread",
	},
	"ember_bow": {
		"display_name": "Ember Bow",
		"description": "Fire-tipped arrows scatter in blazing arcs.",
		"type": "weapon",
		"rarity": "rare",
		"icon_color": Color(1.0, 0.4, 0.1),
		"stats": {"damage": 12.0, "projectile_count": 1, "power_bonus": 8, "attack_speed_base": 1.5},
		"weapon_type": "spread",
	},
	"shadow_bow": {
		"display_name": "Shadow Bow",
		"description": "Arrows of darkness that split into shadow bolts.",
		"type": "weapon",
		"rarity": "epic",
		"icon_color": Color(0.3, 0.05, 0.5),
		"stats": {"damage": 12.0, "projectile_count": 1, "power_bonus": 8, "attack_speed_base": 1.5},
		"weapon_type": "spread",
	},
	"nexus_bow": {
		"display_name": "Nexus Bow",
		"description": "The ultimate bow. Each arrow carries the energy of the nexus.",
		"type": "weapon",
		"rarity": "epic",
		"icon_color": Color(1.0, 0.85, 0.3),
		"stats": {"damage": 12.0, "projectile_count": 1, "power_bonus": 8, "attack_speed_base": 1.5},
		"weapon_type": "spread",
	},

	# ══════════════════════════════════════
	# WEAPONS — Staff Chain (homing)
	# ══════════════════════════════════════
	"ember_staff": {
		"display_name": "Ember Staff",
		"description": "A staff that launches homing fireballs.",
		"type": "weapon",
		"rarity": "rare",
		"icon_color": Color(1.0, 0.5, 0.15),
		"stats": {"damage": 15.0, "power_bonus": 15, "attack_speed_base": 0.9},
		"weapon_type": "homing",
	},
	"void_staff": {
		"display_name": "Void Staff",
		"description": "Shadow orbs seek enemies with unerring precision.",
		"type": "weapon",
		"rarity": "epic",
		"icon_color": Color(0.35, 0.05, 0.55),
		"stats": {"damage": 15.0, "power_bonus": 15, "attack_speed_base": 0.9},
		"weapon_type": "homing",
	},
	"nexus_staff": {
		"display_name": "Nexus Staff",
		"description": "The ultimate staff. Runic projectiles hunt down all foes.",
		"type": "weapon",
		"rarity": "epic",
		"icon_color": Color(1.0, 0.85, 0.3),
		"stats": {"damage": 15.0, "power_bonus": 15, "attack_speed_base": 0.9},
		"weapon_type": "homing",
	},

	# ══════════════════════════════════════
	# WEAPONS — Spear Chain (piercing)
	# ══════════════════════════════════════
	"frost_spear": {
		"display_name": "Frost Spear",
		"description": "An ice lance that pierces through all in its path.",
		"type": "weapon",
		"rarity": "rare",
		"icon_color": Color(0.4, 0.75, 1.0),
		"stats": {"damage": 18.0, "projectile_pierce": 2, "power_bonus": 18, "attack_speed_base": 0.8},
		"weapon_type": "piercing",
	},
	"runed_spear": {
		"display_name": "Runed Spear",
		"description": "Ember runes heat the spearhead. Pierces armor and bone.",
		"type": "weapon",
		"rarity": "rare",
		"icon_color": Color(1.0, 0.5, 0.2),
		"stats": {"damage": 18.0, "projectile_pierce": 2, "power_bonus": 18, "attack_speed_base": 0.8},
		"weapon_type": "piercing",
	},
	"void_spear": {
		"display_name": "Void Spear",
		"description": "A lance of pure darkness. Nothing stops its advance.",
		"type": "weapon",
		"rarity": "epic",
		"icon_color": Color(0.4, 0.1, 0.6),
		"stats": {"damage": 18.0, "projectile_pierce": 2, "power_bonus": 18, "attack_speed_base": 0.8},
		"weapon_type": "piercing",
	},
	"nexus_spear": {
		"display_name": "Nexus Spear",
		"description": "The ultimate spear. Energy trails behind each throw.",
		"type": "weapon",
		"rarity": "epic",
		"icon_color": Color(1.0, 0.85, 0.3),
		"stats": {"damage": 18.0, "projectile_pierce": 2, "power_bonus": 18, "attack_speed_base": 0.8},
		"weapon_type": "piercing",
	},

	# ══════════════════════════════════════
	# WEAPONS — Standalone (not in upgrade chains)
	# ══════════════════════════════════════
	"ember_blade": {
		"display_name": "Ember Blade",
		"description": "A sword wreathed in flame. Projectiles seek out enemies.",
		"type": "weapon",
		"rarity": "rare",
		"icon_color": Color(1.0, 0.4, 0.1),
		"stats": {"damage": 18.0, "fire_rate": 0.08, "power_bonus": 18, "attack_speed_base": 0.9},
		"weapon_type": "homing",
	},
	"void_scythe": {
		"display_name": "Void Scythe",
		"description": "A blade forged from pure darkness. Cuts through all enemies.",
		"type": "weapon",
		"rarity": "epic",
		"icon_color": Color(0.4, 0.0, 0.7),
		"stats": {"damage": 25.0, "projectile_pierce": 2, "power_bonus": 25, "attack_speed_base": 0.7},
		"weapon_type": "piercing",
	},
	"nexus_cannon": {
		"display_name": "Nexus Cannon",
		"description": "The ultimate weapon. Projectiles explode on impact.",
		"type": "weapon",
		"rarity": "epic",
		"icon_color": Color(1.0, 0.9, 0.2),
		"stats": {"damage": 30.0, "projectile_count": 2, "fire_rate": 0.1, "power_bonus": 30, "attack_speed_base": 0.8},
		"weapon_type": "aoe",
	},

	# ══════════════════════════════════════
	# ARMOR — Shield Chain
	# ══════════════════════════════════════
	"slime_shield": {
		"display_name": "Slime Shield",
		"description": "A sticky shield that absorbs hits surprisingly well.",
		"type": "armor",
		"rarity": "uncommon",
		"icon_color": Color(0.3, 0.8, 0.3),
		"stats": {"max_hp": 25.0, "hp_regen": 0.5, "vitality_bonus": 40, "speed_bonus": 10},
	},
	"frost_shield": {
		"display_name": "Frost Shield",
		"description": "Ice-coated shield that chills attackers on contact.",
		"type": "armor",
		"rarity": "rare",
		"icon_color": Color(0.5, 0.8, 1.0),
		"stats": {"max_hp": 25.0, "hp_regen": 0.5, "vitality_bonus": 40, "speed_bonus": 10},
	},
	"ember_shield": {
		"display_name": "Ember Shield",
		"description": "A molten shield that radiates protective heat.",
		"type": "armor",
		"rarity": "rare",
		"icon_color": Color(1.0, 0.4, 0.1),
		"stats": {"max_hp": 25.0, "hp_regen": 0.5, "vitality_bonus": 40, "speed_bonus": 10},
	},
	"void_shield": {
		"display_name": "Void Shield",
		"description": "A barrier woven from shadow. Absorbs attacks into nothing.",
		"type": "armor",
		"rarity": "epic",
		"icon_color": Color(0.35, 0.05, 0.55),
		"stats": {"max_hp": 25.0, "hp_regen": 0.5, "vitality_bonus": 40, "speed_bonus": 10},
	},
	"nexus_shield": {
		"display_name": "Nexus Shield",
		"description": "The ultimate shield. Runic wards deflect all harm.",
		"type": "armor",
		"rarity": "epic",
		"icon_color": Color(1.0, 0.85, 0.3),
		"stats": {"max_hp": 25.0, "hp_regen": 0.5, "vitality_bonus": 40, "speed_bonus": 10},
	},

	# ══════════════════════════════════════
	# ARMOR — Mantle Chain
	# ══════════════════════════════════════
	"void_mantle": {
		"display_name": "Void Mantle",
		"description": "A cloak woven from shadow. Makes you nearly untouchable.",
		"type": "armor",
		"rarity": "epic",
		"icon_color": Color(0.3, 0.05, 0.5),
		"stats": {"max_hp": 80.0, "move_speed": 25.0, "hp_regen": 2.0, "vitality_bonus": 60, "speed_bonus": 5, "luck_bonus": 0.3},
	},
	"nexus_mantle": {
		"display_name": "Nexus Mantle",
		"description": "The ultimate cloak. Bends reality around the wearer.",
		"type": "armor",
		"rarity": "epic",
		"icon_color": Color(1.0, 0.85, 0.3),
		"stats": {"max_hp": 80.0, "move_speed": 25.0, "hp_regen": 2.0, "vitality_bonus": 60, "speed_bonus": 5, "luck_bonus": 0.3},
	},

	# ══════════════════════════════════════
	# ARMOR — Standalone (not in upgrade chains)
	# ══════════════════════════════════════
	"frozen_mail": {
		"display_name": "Frozen Mail",
		"description": "Armor forged from glacial shards. Cold to the touch.",
		"type": "armor",
		"rarity": "rare",
		"icon_color": Color(0.6, 0.85, 1.0),
		"stats": {"max_hp": 40.0, "move_speed": 10.0, "vitality_bonus": 45, "speed_bonus": 15},
	},
	"magma_plate": {
		"display_name": "Magma Plate",
		"description": "Volcanic armor that radiates heat.",
		"type": "armor",
		"rarity": "rare",
		"icon_color": Color(0.9, 0.3, 0.1),
		"stats": {"max_hp": 60.0, "hp_regen": 1.5, "vitality_bonus": 60, "speed_bonus": 5},
	},
	"nexus_aegis": {
		"display_name": "Nexus Aegis",
		"description": "The ultimate shield. Imbued with the power of all runes.",
		"type": "armor",
		"rarity": "epic",
		"icon_color": Color(1.0, 0.85, 0.3),
		"stats": {"max_hp": 100.0, "hp_regen": 3.0, "move_speed": 15.0, "vitality_bonus": 100, "speed_bonus": 15, "luck_bonus": 0.2},
	},

	# ══════════════════════════════════════
	# RUNES
	# ══════════════════════════════════════
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

func _ready() -> void:
	# Compute star tiers after all autoloads are initialized
	call_deferred("_compute_star_tiers")

func _compute_star_tiers() -> void:
	for recipe in RecipeDatabase.get_recipes():
		var result_id: String = recipe["result_id"]
		if not items.has(result_id):
			continue
		var item_type = items[result_id].get("type", "")
		if item_type != "weapon" and item_type != "armor":
			continue
		# Find highest region among material ingredients
		var max_region: int = 1
		for ingredient in recipe["ingredients"]:
			var ing_id: String = ingredient["item_id"]
			if items.has(ing_id):
				var ing_data = items[ing_id]
				if ing_data.get("type", "") == "material":
					var r: int = ing_data.get("region", 1)
					if r > max_region:
						max_region = r
		items[result_id]["star_tier"] = max_region

func get_item(item_id: String) -> Dictionary:
	if items.has(item_id):
		return items[item_id]
	return {}

func get_display_name(item_id: String) -> String:
	var item = get_item(item_id)
	return item.get("display_name", item_id)

func get_star_tier(item_id: String) -> int:
	var item = get_item(item_id)
	return item.get("star_tier", 1)

func get_tier_multiplier(item_id: String) -> float:
	var tier = get_star_tier(item_id)
	if tier >= 1 and tier <= 5:
		return TIER_MULTIPLIERS[tier]
	return 1.0

func get_star_string(item_id: String) -> String:
	var tier = get_star_tier(item_id)
	var s = ""
	for i in range(tier):
		s += "*"
	return s

func get_rarity_color(rarity: String) -> Color:
	match rarity:
		"common": return Color(0.8, 0.8, 0.8)
		"uncommon": return Color(0.3, 0.9, 0.3)
		"rare": return Color(0.3, 0.5, 1.0)
		"epic": return Color(0.8, 0.3, 1.0)
	return Color.WHITE
