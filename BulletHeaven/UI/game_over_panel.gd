extends CanvasLayer

@onready var panel: PanelContainer = $PanelContainer
@onready var score_label: Label = $PanelContainer/VBoxContainer/ScoreLabel
@onready var time_label: Label = $PanelContainer/VBoxContainer/TimeLabel
@onready var kills_label: Label = $PanelContainer/VBoxContainer/KillsLabel
@onready var damage_label: Label = $PanelContainer/VBoxContainer/DamageLabel
@onready var loot_container: VBoxContainer = $PanelContainer/VBoxContainer/LootContainer
@onready var restart_button: Button = $PanelContainer/VBoxContainer/RestartButton
@onready var quit_button: Button = $PanelContainer/VBoxContainer/QuitButton

func _ready() -> void:
	visible = false
	GameManager.game_over.connect(_on_game_over)
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_game_over() -> void:
	score_label.text = "Final Score: %d" % GameManager.score
	time_label.text = "Time Survived: %s" % GameManager.get_time_string()
	kills_label.text = "Enemies Killed: %d" % GameManager.total_kills
	damage_label.text = "Damage Dealt: %d" % int(GameManager.total_damage_dealt)
	_populate_loot_summary()
	visible = true
	get_tree().paused = true
	AudioManager.play_game_over()

func _populate_loot_summary() -> void:
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

func _on_restart_pressed() -> void:
	get_tree().paused = false
	ObjectPool.clear_all()
	GameManager.reset()
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().paused = false
	ObjectPool.clear_all()
	get_tree().change_scene_to_file("res://UI/WorldMap.tscn")
