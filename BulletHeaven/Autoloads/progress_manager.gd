extends Node

## ProgressManager Autoload
## Tracks world map progress: which nodes are completed, which is selected for combat.

var completed_nodes: Array = []
var current_node: Resource = null

func is_node_unlocked(node_data: Resource) -> bool:
	for req in node_data.unlock_requires:
		if req not in completed_nodes:
			return false
	return true

func is_node_completed(node_id: String) -> bool:
	return node_id in completed_nodes

func select_node(node_data: Resource) -> void:
	current_node = node_data
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")

func complete_node(node_id: String) -> void:
	if node_id not in completed_nodes:
		completed_nodes.append(node_id)

func reset() -> void:
	completed_nodes.clear()
	current_node = null
