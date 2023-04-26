extends Area2D

signal hit

var hit := false

onready var collision := $CollisionShape2D


func hit() -> void:
	if hit:
		return
	hit = true
	emit_signal("hit")
	collision.call_deferred("set_disabled", true)


func set_past(past: bool) -> void:
	collision.call_deferred("set_disabled", not past or hit)


func disable() -> void:
	hit = true
	collision.call_deferred("set_disabled", true)
