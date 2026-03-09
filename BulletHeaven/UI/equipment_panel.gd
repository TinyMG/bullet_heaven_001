extends CanvasLayer

## EquipmentPanel
## Shows equipped weapon/armor and allows equipping gear from inventory.

@onready var panel: PanelContainer = $PanelContainer
@onready var weapon_label: Label = $PanelContainer/VBoxContainer/WeaponSection/WeaponLabel
@onready var weapon_stats: Label = $PanelContainer/VBoxContainer/WeaponSection/WeaponStats
@onready var weapon_unequip: Button = $PanelContainer/VBoxContainer/WeaponSection/WeaponUnequip
@onready var armor_label: Label = $PanelContainer/VBoxContainer/ArmorSection/ArmorLabel
@onready var armor_stats: Label = $PanelContainer/VBoxContainer/ArmorSection/ArmorStats
@onready var armor_unequip: Button = $PanelContainer/VBoxContainer/ArmorSection/ArmorUnequip
@onready var gear_list: VBoxContainer = $PanelContainer/VBoxContainer/GearList
@onready var close_button: Button = $PanelContainer/VBoxContainer/CloseButton

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
		weapon_label.text = "Weapon: %s" % data.get("display_name", "Unknown")
		weapon_stats.text = _format_stats(data.get("stats", {}))
		weapon_unequip.visible = true
	else:
		weapon_label.text = "Weapon: None"
		weapon_stats.text = ""
		weapon_unequip.visible = false

	# Update armor slot
	if ProgressManager.equipped_armor != "":
		var data = ItemDatabase.get_item(ProgressManager.equipped_armor)
		armor_label.text = "Armor: %s" % data.get("display_name", "Unknown")
		armor_stats.text = _format_stats(data.get("stats", {}))
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
		if item_type == "weapon" or item_type == "armor":
			var count = ProgressManager.get_item_count(item_id)
			var btn = Button.new()
			btn.text = "Equip %s (%dx)" % [data.get("display_name", item_id), count]
			btn.custom_minimum_size = Vector2(0, 40)
			var stats_text = _format_stats(data.get("stats", {}))
			btn.tooltip_text = stats_text
			# Capture item_id in closure
			var captured_id = item_id
			btn.pressed.connect(func(): ProgressManager.equip_item(captured_id); _refresh())
			gear_list.add_child(btn)

	if gear_list.get_child_count() == 0:
		var empty = Label.new()
		empty.text = "No gear in inventory"
		empty.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		gear_list.add_child(empty)

func _format_stats(stats: Dictionary) -> String:
	var parts: Array = []
	var stat_names = {
		"damage": "DMG", "fire_rate": "Fire Rate", "max_hp": "HP",
		"move_speed": "Speed", "hp_regen": "Regen", "projectile_count": "Shots",
		"projectile_pierce": "Pierce", "pickup_radius": "Pickup",
	}
	for key in stats:
		var label = stat_names.get(key, key)
		var val = stats[key]
		if val > 0:
			parts.append("+%s %s" % [str(val), label])
	return ", ".join(parts)

func _on_close() -> void:
	visible = false
