extends CanvasLayer

## WaveCompletePanel
## Shown when all waves in a map node are cleared. Shows stats and returns to world map.

@onready var panel: PanelContainer = $PanelContainer
@onready var title_label: Label = $PanelContainer/VBoxContainer/TitleLabel
@onready var score_label: Label = $PanelContainer/VBoxContainer/ScoreLabel
@onready var time_label: Label = $PanelContainer/VBoxContainer/TimeLabel
@onready var kills_label: Label = $PanelContainer/VBoxContainer/KillsLabel
@onready var damage_label: Label = $PanelContainer/VBoxContainer/DamageLabel
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
	visible = true
	# Don't pause — let player collect remaining drops/gems first
	# Player presses Continue when they're ready to leave

func _on_continue_pressed() -> void:
	get_tree().paused = false
	ObjectPool.clear_all()
	get_tree().change_scene_to_file("res://UI/WorldMap.tscn")
