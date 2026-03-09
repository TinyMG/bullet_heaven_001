extends CanvasLayer

## BossHPBar
## Shows a large HP bar at the bottom when a boss is active.

@onready var bar: ProgressBar = $ProgressBar
@onready var boss_label: Label = $BossLabel

var tracked_boss: CharacterBody2D = null

func _ready() -> void:
	visible = false

func track_boss(boss: CharacterBody2D) -> void:
	tracked_boss = boss
	visible = true
	bar.max_value = boss.max_hp
	bar.value = boss.current_hp

func _process(_delta: float) -> void:
	if tracked_boss and is_instance_valid(tracked_boss):
		bar.value = tracked_boss.current_hp
	elif visible:
		visible = false
		tracked_boss = null
