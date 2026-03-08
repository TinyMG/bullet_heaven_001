extends Area2D

## Projectile.gd
## Flies in a direction and damages enemies on contact.

@export var speed: float = 400.0
var direction: Vector2 = Vector2.RIGHT
var damage: float = 10.0
var lifetime: float = 3.0

func _ready() -> void:
	add_to_group("Projectile")
	collision_layer = 4
	collision_mask = 2
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	
	# Auto-destroy after lifetime
	var timer = Timer.new()
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.timeout.connect(queue_free)
	add_child(timer)
	timer.start()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_area_entered(_area: Area2D) -> void:
	pass  # We use body_entered for CharacterBody2D enemies

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy") and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()


