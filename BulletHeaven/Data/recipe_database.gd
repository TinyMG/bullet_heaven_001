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
