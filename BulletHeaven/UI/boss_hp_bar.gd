extends CanvasLayer

## BossHPBar
## Shows a large HP bar at the bottom when a boss is active.
## Displays current boss phase info.

@onready var bar: ProgressBar = $ProgressBar
@onready var boss_label: Label = $BossLabel

var tracked_boss: CharacterBody2D = null
var _last_phase: int = -1

func _ready() -> void:
	visible = false

func track_boss(boss: CharacterBody2D) -> void:
	tracked_boss = boss
	_last_phase = -1
	visible = true
	bar.max_value = boss.max_hp
	bar.value = boss.current_hp
	_update_label()

func _process(_delta: float) -> void:
	if tracked_boss and is_instance_valid(tracked_boss):
		bar.value = tracked_boss.current_hp
		if tracked_boss.is_boss and tracked_boss.boss_phase != _last_phase:
			_last_phase = tracked_boss.boss_phase
			_update_label()
	elif visible:
		visible = false
		tracked_boss = null

func _update_label() -> void:
	if not tracked_boss:
		return
	var phase_names = ["BOSS", "BOSS - Phase 2", "BOSS - Phase 3", "BOSS - ENRAGED"]
	var phase = tracked_boss.boss_phase if tracked_boss.is_boss else 0
	boss_label.text = phase_names[clampi(phase, 0, 3)]
	# Color the bar fill based on phase
	var phase_colors = [Color(0.9, 0.1, 0.1), Color(0.9, 0.7, 0.1), Color(0.9, 0.4, 0.1), Color(0.8, 0.1, 0.3)]
	var fill = bar.get_theme_stylebox("fill")
	if fill is StyleBoxFlat:
		fill.bg_color = phase_colors[clampi(phase, 0, 3)]
