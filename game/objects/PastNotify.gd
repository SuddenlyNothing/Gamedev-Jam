extends Area2D

var disabled := false

onready var collision := $CollisionShape2D


func set_past(past: bool) -> void:
	collision.call_deferred("set_disabled", not past or disabled)


func disable() -> void:
	disabled = true
	collision.call_deferred("set_disabled", true)
