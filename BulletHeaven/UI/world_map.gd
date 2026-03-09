extends Node2D

## WorldMap
## Displays map nodes, connection lines, and an info panel for the selected node.

@onready var node_container: Node2D = $NodeContainer
@onready var info_panel: PanelContainer = $CanvasLayer/InfoPanel
@onready var info_name: Label = $CanvasLayer/InfoPanel/VBoxContainer/NameLabel
@onready var info_desc: Label = $CanvasLayer/InfoPanel/VBoxContainer/DescLabel
@onready var info_waves: Label = $CanvasLayer/InfoPanel/VBoxContainer/WavesLabel
@onready var info_difficulty: Label = $CanvasLayer/InfoPanel/VBoxContainer/DifficultyLabel
@onready var rune_label: Label = $CanvasLayer/InfoPanel/VBoxContainer/RuneLabel
@onready var start_button: Button = $CanvasLayer/InfoPanel/VBoxContainer/StartButton
@onready var back_button: Button = $CanvasLayer/BackButton
@onready var inventory_button: Button = $CanvasLayer/InventoryButton
@onready var crafting_button: Button = $CanvasLayer/CraftingButton
@onready var inventory_panel = $InventoryPanel
@onready var crafting_panel = $CraftingPanel

var map_config: Resource = preload("res://Data/Nodes/world_map.tres")
var node_button_scene: PackedScene = preload("res://UI/MapNodeButton.tscn")
var selected_node: Resource = null
var node_positions: Array = []

var region_names: Dictionary = {
	"forest": "Ashwood Forest",
	"tundra": "Frostpeak Tundra",
	"ruins": "Emberveil Ruins",
	"depths": "Shadow Depths",
	"nexus": "The Rune Nexus",
}

func _ready() -> void:
	info_panel.visible = false
	start_button.pressed.connect(_on_start_pressed)
	back_button.pressed.connect(_on_back_pressed)
	inventory_button.pressed.connect(_on_inventory_pressed)
	crafting_button.pressed.connect(_on_crafting_pressed)
	ProgressManager.region_unlocked.connect(_on_region_unlocked)
	_build_map()

func _build_map() -> void:
	node_positions.clear()
	# Clear existing nodes
	for child in node_container.get_children():
		child.queue_free()

	for i in range(map_config.nodes.size()):
		var data = map_config.nodes[i]
		var btn = node_button_scene.instantiate()
		btn.setup(data)
		btn.position = data.position_on_map
		node_container.add_child(btn)
		btn.node_selected.connect(_on_node_selected)
		node_positions.append(data.position_on_map + Vector2(60, 25))

		# Dim nodes from locked regions
		if not ProgressManager.is_region_unlocked(data.region):
			btn.modulate = Color(0.3, 0.3, 0.3, 0.5)
			btn.set_locked_region(true)

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

	# Show rune requirement
	var rune_req: String = data.get("rune_required")
	if rune_req != null and rune_req != "":
		var rune_data = ItemDatabase.get_item(rune_req)
		var rune_name = rune_data.get("display_name", rune_req)
		if ProgressManager.has_item(rune_req):
			rune_label.text = "Requires: %s (owned)" % rune_name
			rune_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
		else:
			rune_label.text = "Requires: %s (missing)" % rune_name
			rune_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
		rune_label.visible = true
	else:
		rune_label.visible = false

	if ProgressManager.is_node_completed(data.node_id):
		start_button.text = "Replay"
		start_button.disabled = false
	elif ProgressManager.is_node_unlocked(data):
		start_button.text = "Start"
		start_button.disabled = false
	else:
		start_button.text = "Locked"
		start_button.disabled = true
	info_panel.visible = true

func _on_start_pressed() -> void:
	if selected_node and ProgressManager.is_node_unlocked(selected_node):
		# Consume rune if required
		ProgressManager.use_rune_for_node(selected_node)
		ProgressManager.save_game()
		ProgressManager.select_node(selected_node)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/MainMenu.tscn")

func _on_inventory_pressed() -> void:
	inventory_panel.show_inventory()

func _on_crafting_pressed() -> void:
	crafting_panel.show_crafting()

func _draw() -> void:
	for conn in map_config.connections:
		if conn.x < node_positions.size() and conn.y < node_positions.size():
			var from = node_positions[conn.x]
			var to = node_positions[conn.y]
			draw_line(from, to, Color(0.5, 0.5, 0.6, 0.6), 2.0)

func _on_region_unlocked(region_id: String) -> void:
	# Rebuild the map to show newly unlocked nodes
	_build_map()
	# Show unlock announcement
	_show_region_unlock_panel(region_id)

func _show_region_unlock_panel(region_id: String) -> void:
	var display_name = region_names.get(region_id, region_id)

	# Full-screen overlay
	var canvas = CanvasLayer.new()
	canvas.layer = 50

	# Dim background
	var bg = ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.0, 0.7)
	bg.anchors_preset = Control.PRESET_FULL_RECT
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	canvas.add_child(bg)

	# Center container
	var center = CenterContainer.new()
	center.anchors_preset = Control.PRESET_FULL_RECT
	canvas.add_child(center)

	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(vbox)

	# "NEW REGION UNLOCKED" header
	var header = Label.new()
	header.text = "NEW REGION UNLOCKED"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 20)
	header.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	vbox.add_child(header)

	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(spacer)

	# Region name
	var name_label = Label.new()
	name_label.text = display_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 32)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(name_label)

	# Spacer
	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(spacer2)

	# Continue button
	var btn = Button.new()
	btn.text = "Continue"
	btn.custom_minimum_size = Vector2(160, 50)
	btn.pressed.connect(func(): canvas.queue_free())
	vbox.add_child(btn)

	add_child(canvas)

	# Animate the header with a pulse
	var tween = header.create_tween()
	tween.set_loops(3)
	tween.tween_property(header, "modulate:a", 0.5, 0.4)
	tween.tween_property(header, "modulate:a", 1.0, 0.4)
