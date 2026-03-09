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
@onready var modifiers_container: VBoxContainer = $CanvasLayer/InfoPanel/VBoxContainer/ModifiersContainer
@onready var modifiers_label: Label = $CanvasLayer/InfoPanel/VBoxContainer/ModifiersLabel
@onready var bonus_label: Label = $CanvasLayer/InfoPanel/VBoxContainer/BonusLabel
@onready var start_button: Button = $CanvasLayer/InfoPanel/VBoxContainer/StartButton
@onready var back_button: Button = $CanvasLayer/BackButton
@onready var inventory_button: Button = $CanvasLayer/InventoryButton
@onready var crafting_button: Button = $CanvasLayer/CraftingButton
@onready var inventory_panel = $InventoryPanel
@onready var crafting_panel = $CraftingPanel
@onready var equipment_panel = $EquipmentPanel
@onready var equip_button: Button = $CanvasLayer/EquipButton

var map_config: Resource = preload("res://Data/Nodes/world_map.tres")
var node_button_scene: PackedScene = preload("res://UI/MapNodeButton.tscn")
var selected_node: Resource = null
var node_positions: Array = []
var scroll_offset: float = 0.0
var scroll_speed: float = 400.0
var max_scroll: float = 0.0

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
	equip_button.pressed.connect(_on_equip_pressed)
	ProgressManager.region_unlocked.connect(_on_region_unlocked)
	_build_map()
	set_process_input(true)

func _input(event: InputEvent) -> void:
	# Mouse wheel scrolling
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			scroll_offset = min(scroll_offset + 60.0, max_scroll)
			node_container.position.y = -scroll_offset
			queue_redraw()
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			scroll_offset = max(scroll_offset - 60.0, 0.0)
			node_container.position.y = -scroll_offset
			queue_redraw()
	# Arrow key scrolling
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_DOWN:
			scroll_offset = min(scroll_offset + 60.0, max_scroll)
			node_container.position.y = -scroll_offset
			queue_redraw()
		elif event.keycode == KEY_UP:
			scroll_offset = max(scroll_offset - 60.0, 0.0)
			node_container.position.y = -scroll_offset
			queue_redraw()

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

	# Calculate scroll range based on node positions
	var max_y: float = 0.0
	for data in map_config.nodes:
		max_y = max(max_y, data.position_on_map.y)
	var viewport_height = get_viewport().get_visible_rect().size.y
	max_scroll = max(0.0, max_y + 100.0 - viewport_height)
	node_container.position.y = -scroll_offset
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

	# Populate modifier checkboxes
	_populate_modifiers(not start_button.disabled)
	info_panel.visible = true

func _on_start_pressed() -> void:
	if selected_node and ProgressManager.is_node_unlocked(selected_node):
		# Collect active modifiers from checkboxes
		ProgressManager.active_modifiers.clear()
		for child in modifiers_container.get_children():
			if child is CheckBox and child.button_pressed:
				ProgressManager.active_modifiers.append(child.name)
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

func _on_equip_pressed() -> void:
	equipment_panel.show_equipment()

func _populate_modifiers(enabled: bool) -> void:
	for child in modifiers_container.get_children():
		child.queue_free()

	for mod_id in ProgressManager.MODIFIER_DEFS:
		var def = ProgressManager.MODIFIER_DEFS[mod_id]
		var cb = CheckBox.new()
		cb.name = mod_id
		cb.text = "%s (+%d%% drops)" % [def["label"], int(def["drop_bonus"] * 100)]
		cb.add_theme_font_size_override("font_size", 12)
		cb.disabled = not enabled
		cb.toggled.connect(_on_modifier_toggled)
		modifiers_container.add_child(cb)

	_update_bonus_label()

func _on_modifier_toggled(_pressed: bool) -> void:
	_update_bonus_label()

func _update_bonus_label() -> void:
	var total_bonus: float = 0.0
	for child in modifiers_container.get_children():
		if child is CheckBox and child.button_pressed:
			var mod_id = child.name
			if ProgressManager.MODIFIER_DEFS.has(mod_id):
				total_bonus += ProgressManager.MODIFIER_DEFS[mod_id]["drop_bonus"]

	if total_bonus > 0.0:
		bonus_label.text = "Drop rate bonus: +%d%%" % int(total_bonus * 100)
	else:
		bonus_label.text = ""

func _draw() -> void:
	var offset = Vector2(0, -scroll_offset)
	for conn in map_config.connections:
		if conn.x < node_positions.size() and conn.y < node_positions.size():
			var from = node_positions[conn.x] + offset
			var to = node_positions[conn.y] + offset
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
