extends CanvasLayer

## EquipmentPanel
## Two-section layout: equipped slots on top, scrollable gear list below.

@onready var weapon_label: Label = $PanelContainer/MarginContainer/VBoxContainer/EquippedSection/WeaponSlot/WeaponContent/WeaponHeader/WeaponLabel
@onready var weapon_stats: Label = $PanelContainer/MarginContainer/VBoxContainer/EquippedSection/WeaponSlot/WeaponContent/WeaponStats
@onready var weapon_unequip: Button = $PanelContainer/MarginContainer/VBoxContainer/EquippedSection/WeaponSlot/WeaponContent/WeaponHeader/WeaponUnequip
@onready var armor_label: Label = $PanelContainer/MarginContainer/VBoxContainer/EquippedSection/ArmorSlot/ArmorContent/ArmorHeader/ArmorLabel
@onready var armor_stats: Label = $PanelContainer/MarginContainer/VBoxContainer/EquippedSection/ArmorSlot/ArmorContent/ArmorStats
@onready var armor_unequip: Button = $PanelContainer/MarginContainer/VBoxContainer/EquippedSection/ArmorSlot/ArmorContent/ArmorHeader/ArmorUnequip
@onready var gear_list: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/GearList
@onready var close_button: Button = $PanelContainer/MarginContainer/VBoxContainer/CloseButton

func _ready() -> void:
	visible = false
	close_button.pressed.connect(_on_close)
	weapon_unequip.pressed.connect(func(): ProgressManager.unequip_item("weapon"); _refresh())
	armor_unequip.pressed.connect(func(): ProgressManager.unequip_item("armor"); _refresh())

func show_equipment() -> void:
	visible = true
	_refresh()

func _refresh() -> void:
	# Update weapon slot
	if ProgressManager.equipped_weapon != "":
		var data = ItemDatabase.get_item(ProgressManager.equipped_weapon)
		var star_str = ItemDatabase.get_star_string(ProgressManager.equipped_weapon)
		var name_text = data.get("display_name", "Unknown")
		if star_str != "":
			name_text += " [%s]" % star_str
		weapon_label.text = name_text
		weapon_stats.text = _format_stats(ProgressManager.equipped_weapon, data.get("stats", {}))
		weapon_unequip.visible = true
	else:
		weapon_label.text = "Weapon: None"
		weapon_stats.text = ""
		weapon_unequip.visible = false

	# Update armor slot
	if ProgressManager.equipped_armor != "":
		var data = ItemDatabase.get_item(ProgressManager.equipped_armor)
		var star_str = ItemDatabase.get_star_string(ProgressManager.equipped_armor)
		var name_text = data.get("display_name", "Unknown")
		if star_str != "":
			name_text += " [%s]" % star_str
		armor_label.text = name_text
		armor_stats.text = _format_stats(ProgressManager.equipped_armor, data.get("stats", {}))
		armor_unequip.visible = true
	else:
		armor_label.text = "Armor: None"
		armor_stats.text = ""
		armor_unequip.visible = false

	# Populate equippable gear from inventory
	for child in gear_list.get_children():
		child.queue_free()

	for item_id in ProgressManager.inventory:
		var data = ItemDatabase.get_item(item_id)
		var item_type = data.get("type", "")
		if item_type != "weapon" and item_type != "armor":
			continue
		var count = ProgressManager.get_item_count(item_id)
		var star_str = ItemDatabase.get_star_string(item_id)
		var display_name = data.get("display_name", item_id)
		if star_str != "":
			display_name += " [%s]" % star_str

		# Create a panel for each gear item
		var item_panel = PanelContainer.new()
		var vbox = VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 2)
		item_panel.add_child(vbox)

		# Name + equip button row
		var hbox = HBoxContainer.new()
		vbox.add_child(hbox)

		var name_label = Label.new()
		name_label.text = "%s (%dx)" % [display_name, count]
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.add_theme_font_size_override("font_size", 13)
		var rarity_color = ItemDatabase.get_rarity_color(data.get("rarity", "common"))
		name_label.add_theme_color_override("font_color", rarity_color)
		hbox.add_child(name_label)

		var equip_btn = Button.new()
		equip_btn.text = "Equip"
		equip_btn.custom_minimum_size = Vector2(60, 24)
		equip_btn.add_theme_font_size_override("font_size", 11)
		var captured_id = item_id
		equip_btn.pressed.connect(func(): ProgressManager.equip_item(captured_id); _refresh())
		hbox.add_child(equip_btn)

		# Stats line
		var stats_label = Label.new()
		stats_label.text = _format_stats(item_id, data.get("stats", {}))
		stats_label.add_theme_font_size_override("font_size", 11)
		stats_label.add_theme_color_override("font_color", Color(0.65, 0.65, 0.65))
		stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vbox.add_child(stats_label)

		gear_list.add_child(item_panel)

	if gear_list.get_child_count() == 0:
		var empty = Label.new()
		empty.text = "No gear in inventory"
		empty.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		gear_list.add_child(empty)

func _format_stats(item_id: String, stats: Dictionary) -> String:
	var parts: Array = []
	var tier_mult = ItemDatabase.get_tier_multiplier(item_id)
	var stat_names = {
		"damage": "DMG", "fire_rate": "Fire Rate", "max_hp": "HP",
		"move_speed": "Speed", "hp_regen": "Regen", "projectile_count": "Shots",
		"projectile_pierce": "Pierce", "pickup_radius": "Pickup",
		"power_bonus": "Power", "attack_speed_base": "Atk Spd",
		"vitality_bonus": "Vitality", "speed_bonus": "Speed",
		"luck_bonus": "Luck",
	}
	var tier_scaled = ["power_bonus", "vitality_bonus", "speed_bonus", "luck_bonus"]
	for key in stats:
		var label = stat_names.get(key, key)
		var val = stats[key]
		if val > 0:
			if key in tier_scaled and tier_mult != 1.0:
				var scaled = val * tier_mult
				parts.append("+%s %s" % [str(snapped(scaled, 0.01)), label])
			else:
				parts.append("+%s %s" % [str(val), label])
	return ", ".join(parts)

func _on_close() -> void:
	visible = false
