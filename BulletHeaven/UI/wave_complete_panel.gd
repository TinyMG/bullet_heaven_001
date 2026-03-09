extends CanvasLayer

## WaveCompletePanel
## Shown when all waves in a map node are cleared. Shows stats and returns to world map.

@onready var panel: PanelContainer = $PanelContainer
@onready var title_label: Label = $PanelContainer/VBoxContainer/TitleLabel
@onready var score_label: Label = $PanelContainer/VBoxContainer/ScoreLabel
@onready var time_label: Label = $PanelContainer/VBoxContainer/TimeLabel
@onready var kills_label: Label = $PanelContainer/VBoxContainer/KillsLabel
@onready var damage_label: Label = $PanelContainer/VBoxContainer/DamageLabel
@onready var loot_container: VBoxContainer = $PanelContainer/VBoxContainer/LootContainer
@onready var continue_button: Button = $PanelContainer/VBoxContainer/ContinueButton

func _ready() -> void:
	visible = false
	GameManager.waves_completed.connect(_on_waves_completed)
	continue_button.pressed.connect(_on_continue_pressed)

func _on_waves_completed() -> void:
	var node_data: Resource = ProgressManager.current_node
	if node_data:
		title_label.text = "%s — Complete!" % node_data.get("display_name")
		ProgressManager.complete_node(node_data.get("node_id"))
	else:
		title_label.text = "Stage Complete!"

	score_label.text = "Score: %d" % GameManager.score
	time_label.text = "Time: %s" % GameManager.get_time_string()
	kills_label.text = "Enemies Killed: %d" % GameManager.total_kills
	damage_label.text = "Damage Dealt: %d" % int(GameManager.total_damage_dealt)
	_populate_loot_summary()
	visible = true
	# Don't pause — let player collect remaining drops/gems first
	# Player presses Continue when they're ready to leave

func _populate_loot_summary() -> void:
	# Clear previous entries
	for child in loot_container.get_children():
		child.queue_free()

	var loot = ProgressManager.run_loot
	if loot.is_empty():
		var none_label = Label.new()
		none_label.text = "No drops collected"
		none_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		none_label.add_theme_font_size_override("font_size", 12)
		none_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		loot_container.add_child(none_label)
		return

	for item_id in loot:
		var count: int = loot[item_id]
		var item_data = ItemDatabase.get_item(item_id)
		var display_name = item_data.get("display_name", item_id)
		var rarity = item_data.get("rarity", "common")
		var color = ItemDatabase.get_rarity_color(rarity)

		var label = Label.new()
		label.text = "%s  x%d" % [display_name, count]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 13)
		label.add_theme_color_override("font_color", color)
		loot_container.add_child(label)

func _on_continue_pressed() -> void:
	get_tree().paused = false
	ObjectPool.clear_all()
	get_tree().change_scene_to_file("res://UI/WorldMap.tscn")
