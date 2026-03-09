extends CanvasLayer

## InventoryPanel
## Shows all items the player has collected. Accessible from the world map.

@onready var panel: PanelContainer = $PanelContainer
@onready var items_container: VBoxContainer = $PanelContainer/VBoxContainer/ScrollContainer/ItemsContainer
@onready var close_button: Button = $PanelContainer/VBoxContainer/CloseButton

func _ready() -> void:
	visible = false
	close_button.pressed.connect(_on_close_pressed)

func show_inventory() -> void:
	_populate()
	visible = true

func _populate() -> void:
	# Clear old entries
	for child in items_container.get_children():
		child.queue_free()

	if ProgressManager.inventory.is_empty():
		var empty_label = Label.new()
		empty_label.text = "No items yet."
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		items_container.add_child(empty_label)
		return

	for item_id in ProgressManager.inventory:
		var count = ProgressManager.inventory[item_id]
		var item_data = ItemDatabase.get_item(item_id)
		if item_data.is_empty():
			continue

		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 10)

		# Color swatch
		var swatch = ColorRect.new()
		swatch.custom_minimum_size = Vector2(16, 16)
		swatch.color = item_data.get("icon_color", Color.WHITE)
		hbox.add_child(swatch)

		# Name + count
		var name_label = Label.new()
		var rarity_color = ItemDatabase.get_rarity_color(item_data.get("rarity", "common"))
		name_label.text = "%s  x%d" % [item_data["display_name"], count]
		name_label.add_theme_color_override("font_color", rarity_color)
		hbox.add_child(name_label)

		items_container.add_child(hbox)

func _on_close_pressed() -> void:
	visible = false
