extends Node

## RecipeDatabase
## Central registry of all crafting recipes. Access via RecipeDatabase.get_recipes().

# Each recipe: { result_id, result_count, ingredients: [{ item_id, count }] }
var recipes: Array[Dictionary] = [
	{
		"result_id": "forest_rune",
		"result_count": 1,
		"ingredients": [
			{"item_id": "wood_shard", "count": 5},
			{"item_id": "dark_petal", "count": 3},
		],
	},
	{
		"result_id": "beast_fang",
		"result_count": 1,
		"ingredients": [
			{"item_id": "wood_shard", "count": 3},
			{"item_id": "dark_petal", "count": 2},
		],
	},
	{
		"result_id": "rune_of_the_wild",
		"result_count": 1,
		"ingredients": [
			{"item_id": "hollow_core", "count": 3},
			{"item_id": "ancient_bark", "count": 4},
			{"item_id": "beast_fang", "count": 2},
		],
	},
	{
		"result_id": "tundra_rune",
		"result_count": 1,
		"ingredients": [
			{"item_id": "frost_wisp", "count": 5},
			{"item_id": "frozen_claw", "count": 3},
		],
	},
	{
		"result_id": "iron_fang_blade",
		"result_count": 1,
		"ingredients": [
			{"item_id": "beast_fang", "count": 6},
			{"item_id": "wood_shard", "count": 4},
		],
	},
	{
		"result_id": "slime_shield",
		"result_count": 1,
		"ingredients": [
			{"item_id": "wood_shard", "count": 8},
			{"item_id": "ancient_bark", "count": 2},
		],
	},
	{
		"result_id": "frost_bow",
		"result_count": 1,
		"ingredients": [
			{"item_id": "frost_wisp", "count": 5},
			{"item_id": "frozen_claw", "count": 4},
			{"item_id": "yeti_heart", "count": 2},
		],
	},
	{
		"result_id": "frozen_mail",
		"result_count": 1,
		"ingredients": [
			{"item_id": "frozen_claw", "count": 6},
			{"item_id": "yeti_heart", "count": 1},
		],
	},
	# Region 3 — Ruins
	{
		"result_id": "rune_of_the_glacier",
		"result_count": 1,
		"ingredients": [
			{"item_id": "yeti_heart", "count": 4},
			{"item_id": "frost_wisp", "count": 8},
			{"item_id": "frozen_claw", "count": 4},
		],
	},
	{
		"result_id": "ruins_rune",
		"result_count": 1,
		"ingredients": [
			{"item_id": "ember_core", "count": 5},
			{"item_id": "molten_shard", "count": 3},
		],
	},
	{
		"result_id": "ember_blade",
		"result_count": 1,
		"ingredients": [
			{"item_id": "ember_core", "count": 8},
			{"item_id": "molten_shard", "count": 4},
			{"item_id": "magma_crystal", "count": 1},
		],
	},
	{
		"result_id": "magma_plate",
		"result_count": 1,
		"ingredients": [
			{"item_id": "molten_shard", "count": 6},
			{"item_id": "magma_crystal", "count": 2},
		],
	},
	# Region 4 — Depths
	{
		"result_id": "rune_of_embers",
		"result_count": 1,
		"ingredients": [
			{"item_id": "magma_crystal", "count": 5},
			{"item_id": "ember_core", "count": 8},
		],
	},
	{
		"result_id": "depths_rune",
		"result_count": 1,
		"ingredients": [
			{"item_id": "void_essence", "count": 5},
			{"item_id": "shadow_silk", "count": 3},
		],
	},
	{
		"result_id": "void_scythe",
		"result_count": 1,
		"ingredients": [
			{"item_id": "void_essence", "count": 8},
			{"item_id": "shadow_silk", "count": 5},
			{"item_id": "void_crown", "count": 2},
		],
	},
	{
		"result_id": "void_mantle",
		"result_count": 1,
		"ingredients": [
			{"item_id": "shadow_silk", "count": 6},
			{"item_id": "void_crown", "count": 3},
		],
	},
	# Region 5 — Nexus
	{
		"result_id": "rune_of_shadows",
		"result_count": 1,
		"ingredients": [
			{"item_id": "void_crown", "count": 5},
			{"item_id": "void_essence", "count": 10},
			{"item_id": "shadow_silk", "count": 4},
		],
	},
	{
		"result_id": "nexus_rune",
		"result_count": 1,
		"ingredients": [
			{"item_id": "rune_fragment", "count": 8},
			{"item_id": "void_essence", "count": 4},
			{"item_id": "ember_core", "count": 4},
		],
	},
	{
		"result_id": "nexus_cannon",
		"result_count": 1,
		"ingredients": [
			{"item_id": "rune_fragment", "count": 10},
			{"item_id": "nexus_core", "count": 3},
			{"item_id": "magma_crystal", "count": 2},
		],
	},
	{
		"result_id": "nexus_aegis",
		"result_count": 1,
		"ingredients": [
			{"item_id": "nexus_core", "count": 4},
			{"item_id": "rune_fragment", "count": 8},
			{"item_id": "void_crown", "count": 2},
		],
	},
]

func get_recipes() -> Array[Dictionary]:
	return recipes

func can_craft(recipe: Dictionary) -> bool:
	for ingredient in recipe["ingredients"]:
		if not ProgressManager.has_item(ingredient["item_id"], ingredient["count"]):
			return false
	return true

func craft(recipe: Dictionary) -> bool:
	if not can_craft(recipe):
		return false
	# Consume ingredients
	for ingredient in recipe["ingredients"]:
		ProgressManager.remove_item(ingredient["item_id"], ingredient["count"])
	# Add result
	ProgressManager.add_item(recipe["result_id"], recipe["result_count"])
	ProgressManager.save_game()
	return true
