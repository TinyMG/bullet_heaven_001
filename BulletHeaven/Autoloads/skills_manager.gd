extends Node

## SkillsManager Autoload
## Holds the skill dictionary, selects random upgrades, and applies stat changes.

signal skill_upgraded(skill_name: String, new_rank: int)

# Each skill: { "description", "max_rank", "current_rank", "effect_per_rank" }
var skills: Dictionary = {
	"fire_rate": {
		"display_name": "Fire Rate",
		"description": "Increases weapon fire rate.",
		"max_rank": 5,
		"current_rank": 0,
		"effect_per_rank": 0.15  # 15% faster per rank
	},
	"damage": {
		"display_name": "Damage",
		"description": "Increases projectile damage.",
		"max_rank": 5,
		"current_rank": 0,
		"effect_per_rank": 5.0  # +5 damage per rank
	},
	"move_speed": {
		"display_name": "Move Speed",
		"description": "Increases player movement speed.",
		"max_rank": 5,
		"current_rank": 0,
		"effect_per_rank": 20.0  # +20 speed per rank
	},
	"pickup_radius": {
		"display_name": "Pickup Radius",
		"description": "Increases XP gem pickup range.",
		"max_rank": 5,
		"current_rank": 0,
		"effect_per_rank": 15.0  # +15 px radius per rank
	},
	"max_hp": {
		"display_name": "Max HP",
		"description": "Increases maximum health.",
		"max_rank": 5,
		"current_rank": 0,
		"effect_per_rank": 10.0  # +10 HP per rank
	},
	"projectile_count": {
		"display_name": "Multishot",
		"description": "Fires additional projectiles.",
		"max_rank": 4,
		"current_rank": 0,
		"effect_per_rank": 1  # +1 extra projectile per rank
	},
	"hp_regen": {
		"display_name": "HP Regen",
		"description": "Regenerate HP over time.",
		"max_rank": 5,
		"current_rank": 0,
		"effect_per_rank": 1.0  # +1 HP/sec per rank
	},
	"projectile_pierce": {
		"display_name": "Pierce",
		"description": "Projectiles pass through enemies.",
		"max_rank": 3,
		"current_rank": 0,
		"effect_per_rank": 1  # +1 pierce per rank
	},
}

func get_random_upgrades(count: int = 3) -> Array:
	var available: Array = []
	for key in skills:
		if skills[key]["current_rank"] < skills[key]["max_rank"]:
			available.append(key)
	available.shuffle()
	return available.slice(0, mini(count, available.size()))

func upgrade_skill(skill_name: String) -> void:
	if not skills.has(skill_name):
		return
	var skill = skills[skill_name]
	if skill["current_rank"] < skill["max_rank"]:
		skill["current_rank"] += 1
		skill_upgraded.emit(skill_name, skill["current_rank"])

func get_skill_value(skill_name: String) -> float:
	if not skills.has(skill_name):
		return 0.0
	var skill = skills[skill_name]
	return skill["current_rank"] * skill["effect_per_rank"]

func reset_all() -> void:
	for key in skills:
		skills[key]["current_rank"] = 0
