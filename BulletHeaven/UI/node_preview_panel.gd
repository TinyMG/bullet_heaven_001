extends CanvasLayer

## NodePreviewPanel
## Full-screen pre-combat screen showing detailed node info, drops, modifiers, and equipment.

signal combat_started
signal closed

var node_data: Resource = null
var _modifier_checkboxes: Array = []

@onready var bg: ColorRect = $Background
@onready var scroll: ScrollContainer = $MarginContainer/ScrollContainer
@onready var content: VBoxContainer = $MarginContainer/ScrollContainer/Content

# Header
@onready var region_banner: PanelContainer = $MarginContainer/ScrollContainer/Content/RegionBanner
@onready var region_label: Label = $MarginContainer/ScrollContainer/Content/RegionBanner/RegionLabel
@onready var node_name_label: Label = $MarginContainer/ScrollContainer/Content/NodeNameLabel
@onready var desc_label: Label = $MarginContainer/ScrollContainer/Content/DescLabel

# Info row
@onready var waves_label: Label = $MarginContainer/ScrollContainer/Content/InfoRow/WavesLabel
@onready var difficulty_label: Label = $MarginContainer/ScrollContainer/Content/InfoRow/DifficultyLabel
@onready var boss_badge: Label = $MarginContainer/ScrollContainer/Content/InfoRow/BossBadge

# Rune requirement
@onready var rune_section: HBoxContainer = $MarginContainer/ScrollContainer/Content/RuneSection
@onready var rune_icon: ColorRect = $MarginContainer/ScrollContainer/Content/RuneSection/RuneIcon
@onready var rune_name_label: Label = $MarginContainer/ScrollContainer/Content/RuneSection/RuneNameLabel
@onready var rune_status_label: Label = $MarginContainer/ScrollContainer/Content/RuneSection/RuneStatusLabel

# Drops
@onready var drops_container: VBoxContainer = $MarginContainer/ScrollContainer/Content/DropsSection/DropsContainer

# Equipment
@onready var weapon_label: Label = $MarginContainer/ScrollContainer/Content/EquipSection/WeaponLabel
@onready var armor_label: Label = $MarginContainer/ScrollContainer/Content/EquipSection/ArmorLabel

# Modifiers
@onready var modifiers_container: VBoxContainer = $MarginContainer/ScrollContainer/Content/ModifiersSection/ModifiersContainer
@onready var bonus_label: Label = $MarginContainer/ScrollContainer/Content/ModifiersSection/BonusLabel

# Buttons
@onready var enter_button: Button = $MarginContainer/ScrollContainer/Content/ButtonRow/EnterButton
@onready var back_button: Button = $MarginContainer/ScrollContainer/Content/ButtonRow/BackButton

var region_colors: Dictionary = {
	"forest": Color(0.3, 0.8, 0.3),
	"tundra": Color(0.4, 0.6, 1.0),
	"ruins": Color(1.0, 0.5, 0.2),
	"depths": Color(0.6, 0.2, 0.8),
	"nexus": Color(1.0, 0.85, 0.2),
}

var region_names: Dictionary = {
	"forest": "Ashwood Forest",
	"tundra": "Frostpeak Tundra",
	"ruins": "Emberveil Ruins",
	"depths": "Shadow Depths",
	"nexus": "The Rune Nexus",
}

func _ready() -> void:
	visible = false
	enter_button.pressed.connect(_on_enter_pressed)
	back_button.pressed.connect(_on_back_pressed)

func show_preview(data: Resource) -> void:
	node_data = data
	_populate_all()
	visible = true

func _populate_all() -> void:
	if node_data == null:
		return

	var region_id: String = node_data.region
	var rc: Color = region_colors.get(region_id, Color.WHITE)

	# Region banner
	var banner_style = StyleBoxFlat.new()
	banner_style.bg_color = Color(rc.r, rc.g, rc.b, 0.3)
	banner_style.border_color = rc
	banner_style.set_border_width_all(2)
	banner_style.set_corner_radius_all(6)
	banner_style.set_content_margin_all(8)
	region_banner.add_theme_stylebox_override("panel", banner_style)
	region_label.text = region_names.get(region_id, region_id).to_upper()
	region_label.add_theme_color_override("font_color", rc)

	# Node name
	node_name_label.text = node_data.display_name

	# Description
	desc_label.text = node_data.description

	# Waves
	waves_label.text = "%d Waves" % node_data.wave_count

	# Difficulty
	var diff_text = "Normal"
	var diff_color = Color(0.5, 1.0, 0.5)
	if node_data.difficulty_modifier >= 1.5:
		diff_text = "Hard"
		diff_color = Color(1.0, 0.4, 0.4)
	elif node_data.difficulty_modifier >= 1.2:
		diff_text = "Medium"
		diff_color = Color(1.0, 0.8, 0.3)
	difficulty_label.text = diff_text
	difficulty_label.add_theme_color_override("font_color", diff_color)

	# Boss badge
	boss_badge.visible = node_data.boss_on_final_wave
	if node_data.boss_on_final_wave:
		boss_badge.text = "BOSS"

	# Rune requirement
	var rune_req: String = node_data.get("rune_required")
	if rune_req != null and rune_req != "":
		rune_section.visible = true
		var rune_data = ItemDatabase.get_item(rune_req)
		var rune_color: Color = rune_data.get("icon_color", Color.WHITE)
		rune_icon.color = rune_color
		rune_name_label.text = rune_data.get("display_name", rune_req)
		if ProgressManager.has_item(rune_req) or ProgressManager.is_node_completed(node_data.node_id):
			rune_status_label.text = "OWNED"
			rune_status_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
		else:
			rune_status_label.text = "MISSING"
			rune_status_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	else:
		rune_section.visible = false

	# Drops
	_populate_drops()

	# Equipment
	weapon_label.text = "Weapon: %s" % ProgressManager.get_equipped_item_name("weapon")
	armor_label.text = "Armor: %s" % ProgressManager.get_equipped_item_name("armor")

	# Modifiers
	_populate_modifiers()

	# Enter button state
	if ProgressManager.is_node_completed(node_data.node_id):
		enter_button.text = "Replay Node"
		enter_button.disabled = false
	elif ProgressManager.is_node_unlocked(node_data):
		enter_button.text = "Enter Combat"
		enter_button.disabled = false
	else:
		enter_button.text = "Locked"
		enter_button.disabled = true

func _populate_drops() -> void:
	# Clear existing drop rows
	for child in drops_container.get_children():
		child.queue_free()

	# Collect drops from both enemy and boss loot tables
	var seen: Dictionary = {}
	var drops: Array = []

	for entry in node_data.enemy_loot_table:
		var item_id: String = entry.get("item_id", "")
		if item_id != "" and not seen.has(item_id):
			seen[item_id] = true
			drops.append({"item_id": item_id, "chance": entry.get("drop_chance", 0.0), "source": "Enemy"})

	for entry in node_data.boss_loot_table:
		var item_id: String = entry.get("item_id", "")
		if item_id != "" and not seen.has(item_id):
			seen[item_id] = true
			drops.append({"item_id": item_id, "chance": entry.get("drop_chance", 0.0), "source": "Boss"})

	if drops.is_empty():
		var empty_label = Label.new()
		empty_label.text = "No drops configured"
		empty_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		drops_container.add_child(empty_label)
		return

	for drop in drops:
		var item_data = ItemDatabase.get_item(drop["item_id"])
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)

		# Color dot
		var dot = ColorRect.new()
		dot.custom_minimum_size = Vector2(14, 14)
		dot.color = item_data.get("icon_color", Color.WHITE)
		var dot_center = CenterContainer.new()
		dot_center.custom_minimum_size = Vector2(14, 20)
		dot_center.add_child(dot)
		row.add_child(dot_center)

		# Item name
		var name_lbl = Label.new()
		name_lbl.text = item_data.get("display_name", drop["item_id"])
		name_lbl.add_theme_font_size_override("font_size", 15)
		var rarity = item_data.get("rarity", "common")
		name_lbl.add_theme_color_override("font_color", ItemDatabase.get_rarity_color(rarity))
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_lbl)

		# Drop rate
		var chance_pct = int(drop["chance"] * 100)
		var chance_lbl = Label.new()
		chance_lbl.text = "%d%%" % chance_pct
		chance_lbl.add_theme_font_size_override("font_size", 14)
		chance_lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		row.add_child(chance_lbl)

		# Source badge
		var source_lbl = Label.new()
		source_lbl.text = drop["source"]
		source_lbl.add_theme_font_size_override("font_size", 12)
		if drop["source"] == "Boss":
			source_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
		else:
			source_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		row.add_child(source_lbl)

		drops_container.add_child(row)

func _populate_modifiers() -> void:
	_modifier_checkboxes.clear()
	for child in modifiers_container.get_children():
		child.queue_free()

	var enabled = not enter_button.disabled

	for mod_id in ProgressManager.MODIFIER_DEFS:
		var def = ProgressManager.MODIFIER_DEFS[mod_id]
		var cb = CheckBox.new()
		cb.name = mod_id
		cb.text = "%s (+%d%% drops)" % [def["label"], int(def["drop_bonus"] * 100)]
		cb.add_theme_font_size_override("font_size", 14)
		cb.disabled = not enabled
		cb.toggled.connect(_on_modifier_toggled)
		modifiers_container.add_child(cb)
		_modifier_checkboxes.append(cb)

	_update_bonus_label()

func _on_modifier_toggled(_pressed: bool) -> void:
	_update_bonus_label()

func _update_bonus_label() -> void:
	var total_bonus: float = 0.0
	for cb in _modifier_checkboxes:
		if cb.button_pressed:
			var mod_id = cb.name
			if ProgressManager.MODIFIER_DEFS.has(mod_id):
				total_bonus += ProgressManager.MODIFIER_DEFS[mod_id]["drop_bonus"]

	if total_bonus > 0.0:
		bonus_label.text = "Drop rate bonus: +%d%%" % int(total_bonus * 100)
		bonus_label.visible = true
	else:
		bonus_label.text = ""
		bonus_label.visible = false

func _on_enter_pressed() -> void:
	if node_data == null:
		return
	# Collect active modifiers
	ProgressManager.active_modifiers.clear()
	for cb in _modifier_checkboxes:
		if cb.button_pressed:
			ProgressManager.active_modifiers.append(cb.name)
	# Consume rune if required
	ProgressManager.use_rune_for_node(node_data)
	ProgressManager.save_game()
	ProgressManager.select_node(node_data)

func _on_back_pressed() -> void:
	visible = false
	closed.emit()
