extends Area2D

## EnemyProjectile — fired by enemies, damages the player on contact.

@export var speed: float = 250.0
var direction: Vector2 = Vector2.RIGHT
var damage: float = 8.0
var lifetime: float = 3.0
var _lifetime_timer: float = 0.0
var _ready_done: bool = false

func _ready() -> void:
	if not _ready_done:
		add_to_group("EnemyProjectile")
		body_entered.connect(_on_body_entered)
		_ready_done = true
	activate()

func activate() -> void:
	visible = true
	set_physics_process(true)
	_lifetime_timer = lifetime
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	_lifetime_timer -= delta
	if _lifetime_timer <= 0.0:
		_release()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body.has_method("take_damage"):
		body.take_damage(damage)
		_release()

func _release() -> void:
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	set_physics_process(false)
	visible = false
	ObjectPool.release_node.call_deferred(self)
