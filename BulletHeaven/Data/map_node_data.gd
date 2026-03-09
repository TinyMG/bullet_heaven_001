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
@export var region: String = "default"
