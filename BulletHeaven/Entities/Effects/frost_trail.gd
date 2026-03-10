extends Area2D

## FrostTrail — slows the player when they walk over it.

var lifetime: float = 4.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	# Self-destruct timer
	var timer = get_tree().create_timer(lifetime)
	timer.timeout.connect(_expire)
	# Fade out visual over lifetime
	var tween = create_tween()
	tween.tween_property($Sprite, "modulate:a", 0.0, lifetime)

func _expire() -> void:
	# Remove slow from player if still overlapping
	for body in get_overlapping_bodies():
		if body.is_in_group("Player") and body.has_method("remove_slow"):
			body.remove_slow()
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body.has_method("apply_slow"):
		body.apply_slow()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player") and body.has_method("remove_slow"):
		body.remove_slow()
