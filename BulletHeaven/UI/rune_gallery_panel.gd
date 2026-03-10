extends CanvasLayer

## RuneGalleryPanel
## Full-screen gallery showing all runes organized by region with state tracking.

# Rune definitions grouped by region, in progression order.
# Each entry: { rune_id, unlocks_node_id (the node this rune opens) }
const RUNE_DATA: Array = [
	# Region 1 — Ashwood Forest
	{"rune_id": "forest_rune", "region": "forest", "unlocks_node": "forest_boss"},
	{"rune_id": "rune_of_the_wild", "region": "forest", "unlocks_node": "tundra_01"},
	# Region 2 — Frostpeak Tundra
	{"rune_id": "tundra_rune", "region": "tundra", "unlocks_node": "tundra_boss"},
	{"rune_id": "rune_of_the_glacier", "region": "tundra", "unlocks_node": "ruins_01"},
	# Region 3 — Emberveil Ruins
	{"rune_id": "ruins_rune", "region": "ruins", "unlocks_node": "ruins_boss"},
	{"rune_id": "rune_of_embers", "region": "ruins", "unlocks_node": "depths_01"},
	# Region 4 — Shadow Depths
	{"rune_id": "depths_rune", "region": "depths", "unlocks_node": "depths_boss"},
	{"rune_id": "rune_of_shadows", "region": "depths", "unlocks_node": "nexus_01"},
	# Region 5 — The Rune Nexus
	{"rune_id": "nexus_rune", "region": "nexus", "unlocks_node": "nexus_boss"},
]

var region_names: Dictionary = {
	"forest": "Ashwood Forest",
	"tundra": "Frostpeak Tundra",
	"ruins": "Emberveil Ruins",
	"depths": "Shadow Depths",
	"nexus": "The Rune Nexus",
}

var region_colors: Dictionary = {
	"forest": Color(0.3, 0.8, 0.3),
	"tundra": Color(0.4, 0.6, 1.0),
	"ruins": Color(1.0, 0.5, 0.2),
	"depths": Color(0.6, 0.2, 0.8),
	"nexus": Color(1.0, 0.85, 0.2),
}

@onready var scroll_container: ScrollContainer = $Background/MarginContainer/VBoxContainer/ScrollContainer
@onready var gallery_container: VBoxContainer = $Background/MarginContainer/VBoxContainer/ScrollContainer/GalleryContainer
@onready var close_button: Button = $Background/MarginContainer/VBoxContainer/CloseButton
@onready var progress_label: Label = $Background/MarginContainer/VBoxContainer/ProgressLabel

func _ready() -> void:
	visible = false
	close_button.pressed.connect(_on_close_pressed)

func show_gallery() -> void:
	_build_gallery()
	visible = true

func _build_gallery() -> void:
	# Clear existing entries
	for child in gallery_container.get_children():
		child.queue_free()

	# Count progress
	var total_runes = RUNE_DATA.size()
	var collected = 0
	for entry in RUNE_DATA:
		var state = _get_rune_state(entry["rune_id"], entry["unlocks_node"])
		if state != "LOCKED":
			collected += 1
	progress_label.text = "Runes Collected: %d / %d" % [collected, total_runes]

	# Build by region
	var current_region = ""
	for entry in RUNE_DATA:
		var rune_id: String = entry["rune_id"]
		var region: String = entry["region"]
		var unlocks_node: String = entry["unlocks_node"]

		# Region header
		if region != current_region:
			current_region = region
			if gallery_container.get_child_count() > 0:
				var spacer = Control.new()
				spacer.custom_minimum_size = Vector2(0, 8)
				gallery_container.add_child(spacer)
			_add_region_header(region)

		# Rune card
		_add_rune_card(rune_id, region, unlocks_node)

func _add_region_header(region: String) -> void:
	var rc: Color = region_colors.get(region, Color.WHITE)
	var header = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(rc.r, rc.g, rc.b, 0.2)
	style.border_color = rc
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)
	style.set_content_margin_all(6)
	header.add_theme_stylebox_override("panel", style)

	var label = Label.new()
	label.text = region_names.get(region, region).to_upper()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", rc)
	header.add_child(label)
	gallery_container.add_child(header)

func _add_rune_card(rune_id: String, region: String, unlocks_node: String) -> void:
	var item_data = ItemDatabase.get_item(rune_id)
	var state = _get_rune_state(rune_id, unlocks_node)
	var rc: Color = region_colors.get(region, Color.WHITE)
	var icon_color: Color = item_data.get("icon_color", Color.WHITE)

	# Card container
	var card = PanelContainer.new()
	var card_style = StyleBoxFlat.new()
	card_style.set_corner_radius_all(6)
	card_style.set_content_margin_all(10)

	match state:
		"USED":
			card_style.bg_color = Color(0.12, 0.12, 0.08, 0.9)
			card_style.border_color = Color(1.0, 0.85, 0.2, 0.6)
			card_style.set_border_width_all(2)
		"CRAFTED":
			card_style.bg_color = Color(0.08, 0.12, 0.08, 0.9)
			card_style.border_color = Color(0.3, 0.9, 0.3, 0.5)
			card_style.set_border_width_all(1)
		"LOCKED":
			card_style.bg_color = Color(0.08, 0.08, 0.08, 0.7)
			card_style.border_color = Color(0.3, 0.3, 0.3, 0.3)
			card_style.set_border_width_all(1)

	card.add_theme_stylebox_override("panel", card_style)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)

	# Rune icon (colored diamond shape via ColorRect)
	var icon_wrapper = CenterContainer.new()
	icon_wrapper.custom_minimum_size = Vector2(40, 40)
	var icon = ColorRect.new()
	icon.custom_minimum_size = Vector2(28, 28)
	if state == "LOCKED":
		icon.color = Color(0.3, 0.3, 0.3, 0.5)
	else:
		icon.color = icon_color
	icon_wrapper.add_child(icon)
	hbox.add_child(icon_wrapper)

	# Text content
	var text_vbox = VBoxContainer.new()
	text_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_vbox.add_theme_constant_override("separation", 3)

	# Name row
	var name_row = HBoxContainer.new()
	name_row.add_theme_constant_override("separation", 8)

	var name_label = Label.new()
	name_label.add_theme_font_size_override("font_size", 17)
	if state == "LOCKED":
		name_label.text = item_data.get("display_name", rune_id)
		name_label.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	else:
		name_label.text = item_data.get("display_name", rune_id)
		var rarity = item_data.get("rarity", "common")
		name_label.add_theme_color_override("font_color", ItemDatabase.get_rarity_color(rarity))
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_row.add_child(name_label)

	# State badge
	var badge = Label.new()
	badge.add_theme_font_size_override("font_size", 12)
	match state:
		"USED":
			badge.text = "USED"
			badge.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
		"CRAFTED":
			badge.text = "READY"
			badge.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
		"LOCKED":
			badge.text = "LOCKED"
			badge.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	name_row.add_child(badge)
	text_vbox.add_child(name_row)

	# Description
	var desc_label = Label.new()
	desc_label.add_theme_font_size_override("font_size", 13)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if state == "LOCKED":
		desc_label.text = "???"
		desc_label.add_theme_color_override("font_color", Color(0.35, 0.35, 0.35))
	else:
		desc_label.text = item_data.get("description", "")
		desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	text_vbox.add_child(desc_label)

	# Recipe info (for locked runes — show what's needed)
	if state == "LOCKED":
		var recipe = _find_recipe(rune_id)
		if recipe:
			var recipe_label = Label.new()
			recipe_label.add_theme_font_size_override("font_size", 12)
			var parts: Array[String] = []
			for ing in recipe["ingredients"]:
				var ing_name = ItemDatabase.get_display_name(ing["item_id"])
				var owned = ProgressManager.get_item_count(ing["item_id"])
				var needed = ing["count"]
				if owned >= needed:
					parts.append("%s %d/%d" % [ing_name, owned, needed])
				else:
					parts.append("%s %d/%d" % [ing_name, owned, needed])
			recipe_label.text = "Recipe: " + ", ".join(parts)
			recipe_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

			# Color based on craftability
			if RecipeDatabase.can_craft(recipe):
				recipe_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
			else:
				recipe_label.add_theme_color_override("font_color", Color(0.6, 0.4, 0.4))
			text_vbox.add_child(recipe_label)

	# "Unlocks: [node name]" info for used runes
	if state == "USED":
		var unlock_label = Label.new()
		unlock_label.add_theme_font_size_override("font_size", 12)
		unlock_label.text = "Unlocked: %s" % unlocks_node.replace("_", " ").capitalize()
		unlock_label.add_theme_color_override("font_color", Color(0.8, 0.7, 0.3))
		text_vbox.add_child(unlock_label)

	hbox.add_child(text_vbox)
	card.add_child(hbox)
	gallery_container.add_child(card)

func _get_rune_state(rune_id: String, unlocks_node: String) -> String:
	# If the node this rune unlocks is completed, the rune was used
	if ProgressManager.is_node_completed(unlocks_node):
		return "USED"
	# If the rune is in inventory, it's crafted and ready
	if ProgressManager.has_item(rune_id):
		return "CRAFTED"
	return "LOCKED"

func _find_recipe(rune_id: String) -> Dictionary:
	for recipe in RecipeDatabase.get_recipes():
		if recipe["result_id"] == rune_id:
			return recipe
	return {}

func _on_close_pressed() -> void:
	visible = false
