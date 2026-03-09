extends CanvasLayer

## CraftingPanel
## Shows all recipes, ingredient requirements, and allows crafting.

@onready var panel: PanelContainer = $PanelContainer
@onready var recipes_container: VBoxContainer = $PanelContainer/VBoxContainer/ScrollContainer/RecipesContainer
@onready var close_button: Button = $PanelContainer/VBoxContainer/CloseButton

func _ready() -> void:
	visible = false
	close_button.pressed.connect(_on_close_pressed)

func show_crafting() -> void:
	_populate()
	visible = true

func _populate() -> void:
	for child in recipes_container.get_children():
		child.queue_free()

	for recipe in RecipeDatabase.get_recipes():
		var recipe_row = _create_recipe_row(recipe)
		recipes_container.add_child(recipe_row)

func _create_recipe_row(recipe: Dictionary) -> PanelContainer:
	var result_data = ItemDatabase.get_item(recipe["result_id"])
	var can_craft = RecipeDatabase.can_craft(recipe)

	var row_panel = PanelContainer.new()
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = Color(0.15, 0.15, 0.2, 1.0)
	stylebox.corner_radius_top_left = 4
	stylebox.corner_radius_top_right = 4
	stylebox.corner_radius_bottom_left = 4
	stylebox.corner_radius_bottom_right = 4
	stylebox.content_margin_left = 10
	stylebox.content_margin_right = 10
	stylebox.content_margin_top = 8
	stylebox.content_margin_bottom = 8
	row_panel.add_theme_stylebox_override("panel", stylebox)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	row_panel.add_child(vbox)

	# Result line
	var result_hbox = HBoxContainer.new()
	result_hbox.add_theme_constant_override("separation", 8)
	var result_swatch = ColorRect.new()
	result_swatch.custom_minimum_size = Vector2(18, 18)
	result_swatch.color = result_data.get("icon_color", Color.WHITE)
	result_hbox.add_child(result_swatch)
	var result_label = Label.new()
	var rarity = result_data.get("rarity", "common")
	result_label.text = "%s  x%d" % [result_data.get("display_name", recipe["result_id"]), recipe["result_count"]]
	result_label.add_theme_color_override("font_color", ItemDatabase.get_rarity_color(rarity))
	result_label.add_theme_font_size_override("font_size", 16)
	result_hbox.add_child(result_label)
	vbox.add_child(result_hbox)

	# Ingredients
	for ingredient in recipe["ingredients"]:
		var ing_data = ItemDatabase.get_item(ingredient["item_id"])
		var have = ProgressManager.get_item_count(ingredient["item_id"])
		var need = ingredient["count"]

		var ing_hbox = HBoxContainer.new()
		ing_hbox.add_theme_constant_override("separation", 6)

		var spacer = Control.new()
		spacer.custom_minimum_size = Vector2(20, 0)
		ing_hbox.add_child(spacer)

		var ing_swatch = ColorRect.new()
		ing_swatch.custom_minimum_size = Vector2(12, 12)
		ing_swatch.color = ing_data.get("icon_color", Color.GRAY)
		ing_hbox.add_child(ing_swatch)

		var ing_label = Label.new()
		ing_label.text = "%s  %d / %d" % [ing_data.get("display_name", ingredient["item_id"]), have, need]
		if have >= need:
			ing_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
		else:
			ing_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
		ing_label.add_theme_font_size_override("font_size", 13)
		ing_hbox.add_child(ing_label)

		vbox.add_child(ing_hbox)

	# Craft button
	var craft_btn = Button.new()
	craft_btn.text = "Craft" if can_craft else "Not enough materials"
	craft_btn.custom_minimum_size = Vector2(0, 36)
	craft_btn.disabled = not can_craft
	craft_btn.pressed.connect(_on_craft_pressed.bind(recipe))
	vbox.add_child(craft_btn)

	return row_panel

func _on_craft_pressed(recipe: Dictionary) -> void:
	if RecipeDatabase.craft(recipe):
		ProgressManager.save_game()
		# Flash success glow before repopulating
		var result_name = ItemDatabase.get_display_name(recipe["result_id"])
		_show_craft_glow(result_name)
		_populate()

func _show_craft_glow(item_name: String) -> void:
	var flash = ColorRect.new()
	flash.color = Color(0.2, 1.0, 0.3, 0.4)
	flash.anchors_preset = Control.PRESET_FULL_RECT
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(flash)

	var label = Label.new()
	label.text = "Crafted %s!" % item_name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.anchors_preset = Control.PRESET_CENTER
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color(0.1, 1.0, 0.3))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	label.add_theme_constant_override("outline_size", 3)
	flash.add_child(label)

	var tween = flash.create_tween()
	tween.tween_property(flash, "color:a", 0.0, 0.6)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.6).set_delay(0.3)
	tween.tween_callback(flash.queue_free)

func _on_close_pressed() -> void:
	visible = false
