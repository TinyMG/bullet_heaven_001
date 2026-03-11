extends Node

## PlayerStats Autoload
## Centralized stat system. Stores base stats, gear bonuses, and per-run level multipliers.
## final_stat = (base_stat + gear_flat_bonus) * level_multiplier

signal stats_changed

# --- Base Stats ---
const BASE_POWER: float = 10.0
const BASE_VITALITY: float = 100.0
const BASE_SPEED: float = 150.0
const BASE_ATTACK_SPEED: float = 1.0  # attacks per second
const BASE_LUCK: float = 1.0

# --- Per-run level multipliers (reset each run) ---
var power_multiplier: float = 1.0
var vitality_multiplier: float = 1.0
var speed_multiplier: float = 1.0
var attack_speed_multiplier: float = 1.0

# Per-stack bonuses (how much each level-up choice adds)
const POWER_PER_STACK: float = 0.08       # +8%
const VITALITY_PER_STACK: float = 0.10     # +10%
const SPEED_PER_STACK: float = 0.06        # +6%
const ATTACK_SPEED_PER_STACK: float = 0.05 # +5%

# Stack counts (for display / max tracking)
var power_stacks: int = 0
var vitality_stacks: int = 0
var speed_stacks: int = 0
var attack_speed_stacks: int = 0

const MAX_STACKS: int = 10
const ATTACK_SPEED_CAP: float = 3.0
const LUCK_CAP: float = 2.5

# --- Per-run upgrade flags (reset each run) ---
var vampiric_active: bool = false       # Heal 3 HP on kill
var volatile_active: bool = false       # Bullets explode on hit
var magnetic_bonus: float = 0.0         # Extra pickup radius (px)
var run_luck_bonus: float = 0.0         # Temporary luck from Fortune's Eye

# --- Computed final stats ---
var final_power: float = BASE_POWER
var final_vitality: float = BASE_VITALITY
var final_speed: float = BASE_SPEED
var final_attack_speed: float = BASE_ATTACK_SPEED
var final_luck: float = BASE_LUCK

func _ready() -> void:
	ProgressManager.equipment_changed.connect(_on_equipment_changed)
	recalculate()

func _on_equipment_changed() -> void:
	recalculate()

func recalculate() -> void:
	# Gear flat bonuses from equipped items
	var gear_power: float = _get_gear_stat("power_bonus")
	var gear_vitality: float = _get_gear_stat("vitality_bonus")
	var gear_speed: float = _get_gear_stat("speed_bonus")
	var gear_luck: float = _get_gear_stat("luck_bonus")

	# Weapon attack speed base overrides default
	var weapon_as_base: float = BASE_ATTACK_SPEED
	if ProgressManager.equipped_weapon != "":
		var data = ItemDatabase.get_item(ProgressManager.equipped_weapon)
		var stats = data.get("stats", {})
		if stats.has("attack_speed_base"):
			weapon_as_base = stats["attack_speed_base"]

	# Update multipliers from stacks
	power_multiplier = 1.0 + power_stacks * POWER_PER_STACK
	vitality_multiplier = 1.0 + vitality_stacks * VITALITY_PER_STACK
	speed_multiplier = 1.0 + speed_stacks * SPEED_PER_STACK
	attack_speed_multiplier = 1.0 + attack_speed_stacks * ATTACK_SPEED_PER_STACK

	# final_stat = (base + gear_flat) * level_multiplier
	final_power = (BASE_POWER + gear_power) * power_multiplier
	final_vitality = (BASE_VITALITY + gear_vitality) * vitality_multiplier
	final_speed = (BASE_SPEED + gear_speed) * speed_multiplier
	final_attack_speed = minf(weapon_as_base * attack_speed_multiplier, ATTACK_SPEED_CAP)
	final_luck = minf(BASE_LUCK + gear_luck + run_luck_bonus, LUCK_CAP)

	stats_changed.emit()

func _get_gear_stat(stat_name: String) -> float:
	var total: float = 0.0
	if ProgressManager.equipped_weapon != "":
		var data = ItemDatabase.get_item(ProgressManager.equipped_weapon)
		var stats = data.get("stats", {})
		var tier_mult = ItemDatabase.get_tier_multiplier(ProgressManager.equipped_weapon)
		total += stats.get(stat_name, 0.0) * tier_mult
	if ProgressManager.equipped_armor != "":
		var data = ItemDatabase.get_item(ProgressManager.equipped_armor)
		var stats = data.get("stats", {})
		var tier_mult = ItemDatabase.get_tier_multiplier(ProgressManager.equipped_armor)
		total += stats.get(stat_name, 0.0) * tier_mult
	return total

func add_stat_stack(stat_name: String) -> void:
	match stat_name:
		"power":
			power_stacks += 1
		"vitality":
			vitality_stacks += 1
		"speed":
			speed_stacks += 1
		"attack_speed":
			attack_speed_stacks += 1
	recalculate()

func get_stack_count(stat_name: String) -> int:
	match stat_name:
		"power": return power_stacks
		"vitality": return vitality_stacks
		"speed": return speed_stacks
		"attack_speed": return attack_speed_stacks
	return 0

func is_stat_maxed(stat_name: String) -> bool:
	return get_stack_count(stat_name) >= MAX_STACKS

func is_attack_speed_at_cap() -> bool:
	return final_attack_speed >= ATTACK_SPEED_CAP

# --- Preview helpers (simulate stat after hypothetical upgrade) ---

func preview_power() -> float:
	var gear_power: float = _get_gear_stat("power_bonus")
	return (BASE_POWER + gear_power) * (1.0 + (power_stacks + 1) * POWER_PER_STACK)

func preview_vitality() -> float:
	var gear_vitality: float = _get_gear_stat("vitality_bonus")
	return (BASE_VITALITY + gear_vitality) * (1.0 + (vitality_stacks + 1) * VITALITY_PER_STACK)

func preview_speed() -> float:
	var gear_speed: float = _get_gear_stat("speed_bonus")
	return (BASE_SPEED + gear_speed) * (1.0 + (speed_stacks + 1) * SPEED_PER_STACK)

func preview_attack_speed() -> float:
	var weapon_as_base: float = BASE_ATTACK_SPEED
	if ProgressManager.equipped_weapon != "":
		var data = ItemDatabase.get_item(ProgressManager.equipped_weapon)
		var stats = data.get("stats", {})
		if stats.has("attack_speed_base"):
			weapon_as_base = stats["attack_speed_base"]
	return minf(weapon_as_base * (1.0 + (attack_speed_stacks + 1) * ATTACK_SPEED_PER_STACK), ATTACK_SPEED_CAP)

func preview_luck() -> float:
	var gear_luck: float = _get_gear_stat("luck_bonus")
	return minf(BASE_LUCK + gear_luck + run_luck_bonus + 0.15, LUCK_CAP)

func preview_magnetic() -> float:
	return 120.0 + magnetic_bonus + 40.0  # base_magnet_radius + current bonus + new bonus

func reset_run_bonuses() -> void:
	power_stacks = 0
	vitality_stacks = 0
	speed_stacks = 0
	attack_speed_stacks = 0
	power_multiplier = 1.0
	vitality_multiplier = 1.0
	speed_multiplier = 1.0
	attack_speed_multiplier = 1.0
	vampiric_active = false
	volatile_active = false
	magnetic_bonus = 0.0
	run_luck_bonus = 0.0
	recalculate()
