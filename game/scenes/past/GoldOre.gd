extends Area2D

signal collected

const Gold := preload("res://scenes/past/Gold.tscn")

var time := 0.0
var interval := 0.02

onready var timer := $Timer
onready var sprite := $Sprite
onready var origin: Vector2 = sprite.position
onready var collision_shape := $CollisionShape2D


func _ready() -> void:
	set_process(false)


func _process(delta: float) -> void:
	time += delta
	if time > interval:
		sprite.position = origin + Vector2((randf() - 0.5) * 5,
				(randf() - 0.5) * 5)
		time = fmod(time, interval)


func set_past(past: bool) -> void:
	collision_shape.call_deferred("set_disabled", not past)


func _on_GoldOre_body_entered(body: Node) -> void:
	show()
	timer.start()
	set_process(true)


func _on_GoldOre_body_exited(body: Node) -> void:
	timer.stop()
	set_process(false)
	sprite.position = origin


func _on_Timer_timeout() -> void:
	var gold := Gold.instance()
	gold.position = position
	get_parent().add_child(gold)
	emit_signal("collected")
	queue_free()
