extends CanvasLayer

## LevelUpPanel.gd
## Pauses the game and shows 3 random upgrade cards from a pool of 8.

@onready var panel: PanelContainer = $PanelContainer
@onready var cards_container: HBoxContainer = $PanelContainer/VBoxContainer/CardsContainer
@onready var title_label: Label = $PanelContainer/VBoxContainer/TitleLabel

# Icon colors for each upgrade
const ICON_COLORS: Dictionary = {
	"sharpen": Color(1.0, 0.3, 0.2),
	"toughen": Color(0.2, 0.9, 0.3),
	"quicken": Color(0.3, 0.7, 1.0),
	"accelerate": Color(1.0, 0.8, 0.2),
	"vampiric": Color(0.8, 0.1, 0.2),
	"magnetic": Color(0.6, 0.4, 1.0),
	"volatile": Color(1.0, 0.5, 0.0),
	"fortunes_eye": Color(0.9, 0.85, 0.2),
}

func _ready() -> void:
	panel.visible = false
	GameManager.player_leveled_up.connect(_on_player_leveled_up)

func _on_player_leveled_up(new_level: int) -> void:
	title_label.text = "Level Up! (Lv. %d)" % new_level
	_show_choices()

func _get_available_upgrades() -> Array:
	var pool: Array = []

	# 1. Sharpen — +8% Power
	if not PlayerStats.is_stat_maxed("power"):
		pool.append({
			"id": "sharpen",
			"name": "Sharpen",
			"description": "Your attacks hit harder.",
			"preview": "Power: %.1f → %.1f" % [PlayerStats.final_power, PlayerStats.preview_power()],
		})

	# 2. Toughen — +10% Vitality + heal 15
	if not PlayerStats.is_stat_maxed("vitality"):
		pool.append({
			"id": "toughen",
			"name": "Toughen",
			"description": "Your body grows more resilient.",
			"preview": "Vitality: %.0f → %.0f (+15 heal)" % [PlayerStats.final_vitality, PlayerStats.preview_vitality()],
		})

	# 3. Quicken — +6% Speed
	if not PlayerStats.is_stat_maxed("speed"):
		pool.append({
			"id": "quicken",
			"name": "Quicken",
			"description": "Your feet move faster.",
			"preview": "Speed: %.0f → %.0f" % [PlayerStats.final_speed, PlayerStats.preview_speed()],
		})

	# 4. Accelerate — +5% Attack Speed (respect cap)
	if not PlayerStats.is_stat_maxed("attack_speed"):
		if PlayerStats.is_attack_speed_at_cap():
			pool.append({
				"id": "accelerate",
				"name": "Accelerate",
				"description": "Your strike rhythm increases.",
				"preview": "MAXED (%.1f cap)" % PlayerStats.ATTACK_SPEED_CAP,
			})
		else:
			pool.append({
				"id": "accelerate",
				"name": "Accelerate",
				"description": "Your strike rhythm increases.",
				"preview": "Atk Speed: %.2f → %.2f" % [PlayerStats.final_attack_speed, PlayerStats.preview_attack_speed()],
			})

	# 5. Vampiric — heal 3 HP on kill (only offer once)
	if not PlayerStats.vampiric_active:
		pool.append({
			"id": "vampiric",
			"name": "Vampiric",
			"description": "Each death feeds your strength.",
			"preview": "Heal 3 HP per kill",
		})

	# 6. Magnetic — +40px pickup radius
	pool.append({
		"id": "magnetic",
		"name": "Magnetic",
		"description": "Drops are drawn to you.",
		"preview": "Pickup: %.0f → %.0f px" % [120.0 + PlayerStats.magnetic_bonus, PlayerStats.preview_magnetic()],
	})

	# 7. Volatile — bullets explode (only if non-AoE weapon, only offer once)
	if not PlayerStats.volatile_active:
		var weapon_type = "standard"
		if ProgressManager.equipped_weapon != "":
			var data = ItemDatabase.get_item(ProgressManager.equipped_weapon)
			weapon_type = data.get("weapon_type", "standard")
		if weapon_type != "aoe":
			pool.append({
				"id": "volatile",
				"name": "Volatile",
				"description": "Your power radiates outward.",
				"preview": "Bullets explode for 40% AoE",
			})

	# 8. Fortune's Eye — +0.15 Luck (only if below 2.0)
	if PlayerStats.final_luck < 2.0:
		pool.append({
			"id": "fortunes_eye",
			"name": "Fortune's Eye",
			"description": "The odds bend slightly in your favor.",
			"preview": "Luck: %.2f → %.2f" % [PlayerStats.final_luck, PlayerStats.preview_luck()],
		})

	return pool

func _show_choices() -> void:
	get_tree().paused = true
	panel.visible = true
	AudioManager.play_level_up()

	# Clear old cards
	for child in cards_container.get_children():
		child.queue_free()

	var pool = _get_available_upgrades()
	if pool.is_empty():
		_close()
		return

	# Pick 3 random, no duplicates
	pool.shuffle()
	var choices = pool.slice(0, mini(3, pool.size()))

	for choice in choices:
		var card = _build_card(choice)
		cards_container.add_child(card)

func _build_card(data: Dictionary) -> PanelContainer:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(200, 160)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Card background style
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.12, 0.18, 0.95)
	style.border_color = ICON_COLORS.get(data["id"], Color.WHITE).lightened(0.2)
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_width_left = 2
	style.border_width_right = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	card.add_theme_stylebox_override("panel", style)

	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER

	# Icon (colored circle)
	var icon_color = ICON_COLORS.get(data["id"], Color.WHITE)
	var icon = ColorRect.new()
	icon.custom_minimum_size = Vector2(28, 28)
	icon.color = icon_color
	# Wrap icon to center it vertically
	var icon_margin = MarginContainer.new()
	icon_margin.add_theme_constant_override("margin_right", 10)
	icon_margin.add_child(icon)
	hbox.add_child(icon_margin)

	# Text column
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 4)

	# Name (large, bold)
	var name_label = Label.new()
	name_label.text = data["name"]
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(name_label)

	# Description
	var desc_label = Label.new()
	desc_label.text = data["description"]
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(desc_label)

	# Stat preview
	var preview_label = Label.new()
	preview_label.text = data["preview"]
	preview_label.add_theme_font_size_override("font_size", 13)
	preview_label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.6))
	preview_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(preview_label)

	hbox.add_child(vbox)

	# Make entire card clickable with a Button overlay
	var btn = Button.new()
	btn.flat = true
	btn.anchors_preset = Control.PRESET_FULL_RECT
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.pressed.connect(_on_card_selected.bind(data["id"]))
	# Hover effect
	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = Color(1, 1, 1, 0.08)
	hover_style.corner_radius_top_left = 8
	hover_style.corner_radius_top_right = 8
	hover_style.corner_radius_bottom_left = 8
	hover_style.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("hover", hover_style)
	var empty_style = StyleBoxEmpty.new()
	btn.add_theme_stylebox_override("normal", empty_style)
	btn.add_theme_stylebox_override("pressed", empty_style)
	btn.add_theme_stylebox_override("focus", empty_style)

	card.add_child(hbox)
	card.add_child(btn)

	return card

func _on_card_selected(upgrade_id: String) -> void:
	match upgrade_id:
		"sharpen":
			PlayerStats.add_stat_stack("power")
		"toughen":
			PlayerStats.add_stat_stack("vitality")
			# Instant heal 15 HP
			var player = GameManager.player
			if player:
				player.current_hp = minf(player.current_hp + 15.0, player.max_hp)
		"quicken":
			PlayerStats.add_stat_stack("speed")
		"accelerate":
			PlayerStats.add_stat_stack("attack_speed")
		"vampiric":
			PlayerStats.vampiric_active = true
		"magnetic":
			PlayerStats.magnetic_bonus += 40.0
			# Update magnet radius immediately
			var player = GameManager.player
			if player:
				player._update_magnet_radius()
		"volatile":
			PlayerStats.volatile_active = true
		"fortunes_eye":
			PlayerStats.run_luck_bonus += 0.15
			PlayerStats.recalculate()
	_close()

func _close() -> void:
	panel.visible = false
	get_tree().paused = false
