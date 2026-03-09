extends Node2D

## WorldMap
## Displays map nodes, connection lines, and an info panel for the selected node.

@onready var node_container: Node2D = $NodeContainer
@onready var info_panel: PanelContainer = $CanvasLayer/InfoPanel
@onready var info_name: Label = $CanvasLayer/InfoPanel/VBoxContainer/NameLabel
@onready var info_desc: Label = $CanvasLayer/InfoPanel/VBoxContainer/DescLabel
@onready var info_waves: Label = $CanvasLayer/InfoPanel/VBoxContainer/WavesLabel
@onready var info_difficulty: Label = $CanvasLayer/InfoPanel/VBoxContainer/DifficultyLabel
@onready var start_button: Button = $CanvasLayer/InfoPanel/VBoxContainer/StartButton
@onready var back_button: Button = $CanvasLayer/BackButton
@onready var inventory_button: Button = $CanvasLayer/InventoryButton
@onready var inventory_panel = $InventoryPanel

var map_config: Resource = preload("res://Data/Nodes/world_map.tres")
var node_button_scene: PackedScene = preload("res://UI/MapNodeButton.tscn")
var selected_node: Resource = null
var node_positions: Array = []

func _ready() -> void:
	info_panel.visible = false
	start_button.pressed.connect(_on_start_pressed)
	back_button.pressed.connect(_on_back_pressed)
	inventory_button.pressed.connect(_on_inventory_pressed)
	_build_map()

func _build_map() -> void:
	node_positions.clear()

	for i in range(map_config.nodes.size()):
		var data = map_config.nodes[i]
		var btn = node_button_scene.instantiate()
		btn.setup(data)
		btn.position = data.position_on_map
		node_container.add_child(btn)
		btn.node_selected.connect(_on_node_selected)
		node_positions.append(data.position_on_map + Vector2(60, 25))

	queue_redraw()

func _on_node_selected(data: Resource) -> void:
	selected_node = data
	info_name.text = data.display_name
	info_desc.text = data.description
	info_waves.text = "Waves: %d" % data.wave_count
	var diff_text = "Normal"
	if data.difficulty_modifier >= 1.5:
		diff_text = "Hard"
	elif data.difficulty_modifier >= 1.2:
		diff_text = "Medium"
	info_difficulty.text = "Difficulty: %s" % diff_text
	if data.boss_on_final_wave:
		info_waves.text += " (Boss)"

	if ProgressManager.is_node_completed(data.node_id):
		start_button.text = "Replay"
	else:
		start_button.text = "Start"
	info_panel.visible = true

func _on_start_pressed() -> void:
	if selected_node:
		ProgressManager.select_node(selected_node)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/MainMenu.tscn")

func _on_inventory_pressed() -> void:
	inventory_panel.show_inventory()

func _draw() -> void:
	for conn in map_config.connections:
		if conn.x < node_positions.size() and conn.y < node_positions.size():
			var from = node_positions[conn.x]
			var to = node_positions[conn.y]
			draw_line(from, to, Color(0.5, 0.5, 0.6, 0.6), 2.0)
