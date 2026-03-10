class_name MapNodeData
extends Resource

@export var node_id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var position_on_map: Vector2 = Vector2.ZERO
@export var wave_count: int = 5
@export var base_enemies_per_wave: int = 3
@export var enemy_hp_base: float = 20.0
@export var enemy_hp_per_wave: float = 2.0
@export var boss_on_final_wave: bool = true
@export var difficulty_modifier: float = 1.0
@export var unlock_requires: Array[String] = []
@export var rune_required: String = ""  # item_id of rune needed to unlock this node
@export var region: String = "default"
@export var enemy_scene_path: String = ""  # Custom enemy scene (e.g. "res://Entities/Enemy/SlimeEnemy.tscn")
@export var boss_scene_path: String = ""  # Custom boss scene (e.g. "res://Entities/Enemy/BossSlime.tscn")

# Loot table: array of { "item_id": String, "drop_chance": float (0.0-1.0) }
# Regular enemies roll from this table on death
@export var enemy_loot_table: Array[Dictionary] = []
# Boss drops (guaranteed)
@export var boss_loot_table: Array[Dictionary] = []
