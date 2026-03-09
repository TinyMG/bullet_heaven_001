extends CanvasLayer

## CombatMinimap
## Small radar in the upper-right showing player and enemy positions.

@onready var draw_control: Control = $DrawControl

func _ready() -> void:
	layer = 5

func _process(_delta: float) -> void:
	draw_control.queue_redraw()
