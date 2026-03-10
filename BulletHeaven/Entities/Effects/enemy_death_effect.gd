extends GPUParticles2D

## EnemyDeathEffect — pool-compatible particle burst on enemy death.

var _ready_done: bool = false
var _release_timer: float = 0.0
var _default_amount: int = 12

func _ready() -> void:
	if not _ready_done:
		_default_amount = amount
		_ready_done = true

func activate(boss: bool = false) -> void:
	if boss:
		amount = 30
		scale = Vector2(3.0, 3.0)
	else:
		amount = _default_amount
		scale = Vector2.ONE
	emitting = true
	visible = true
	_release_timer = lifetime + 0.2  # Wait for particles to finish
	set_process(true)

func _process(delta: float) -> void:
	_release_timer -= delta
	if _release_timer <= 0.0:
		_release()

func _release() -> void:
	emitting = false
	visible = false
	set_process(false)
	ObjectPool.release_node.call_deferred(self)
