extends CanvasLayer

## LevelUpPanel.gd
## Pauses the game and shows 3 random skill upgrade choices.

@onready var panel: PanelContainer = $PanelContainer
@onready var buttons_container: VBoxContainer = $PanelContainer/VBoxContainer/ButtonsContainer
@onready var title_label: Label = $PanelContainer/VBoxContainer/TitleLabel

func _ready() -> void:
	panel.visible = false
	GameManager.player_leveled_up.connect(_on_player_leveled_up)

func _on_player_leveled_up(new_level: int) -> void:
	title_label.text = "Level Up! (Lv. %d)" % new_level
	_show_choices()

func _show_choices() -> void:
	# Pause the game
	get_tree().paused = true
	panel.visible = true
	AudioManager.play_level_up()
	
	# Clear old buttons
	for child in buttons_container.get_children():
		child.queue_free()
	
	# Get random upgrades
	var upgrades = SkillsManager.get_random_upgrades(3)
	
	if upgrades.is_empty():
		# All skills maxed out
		_close()
		return
	
	for skill_key in upgrades:
		var skill = SkillsManager.skills[skill_key]
		var btn = Button.new()
		btn.text = "%s (Rank %d/%d)\n%s" % [
			skill["display_name"],
			skill["current_rank"] + 1,
			skill["max_rank"],
			skill["description"]
		]
		btn.custom_minimum_size = Vector2(300, 60)
		btn.pressed.connect(_on_upgrade_selected.bind(skill_key))
		buttons_container.add_child(btn)

func _on_upgrade_selected(skill_key: String) -> void:
	SkillsManager.upgrade_skill(skill_key)
	_close()

func _close() -> void:
	panel.visible = false
	get_tree().paused = false
