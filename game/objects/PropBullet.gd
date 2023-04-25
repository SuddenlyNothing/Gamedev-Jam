extends Area2D

var speed := 500.0
var stop_point: float
var velocity := -speed
var ignore := false

onready var collision_shape := $CollisionShape2D
onready var friction := pow(speed, 2) / (abs(position.x - stop_point) * 2)


func _physics_process(delta: float) -> void:
	if ignore:
		position.x -= speed * delta
	else:
		var friction_amount := friction * delta
		velocity += friction_amount
		if velocity >= 0:
			set_physics_process(false)
		else:
			position.x += velocity * delta


func set_past(past: bool) -> void:
	ignore = true
	set_physics_process(past)
	collision_shape.call_deferred("set_disabled", not past)


func _on_PropBullet_body_entered(body: Node) -> void:
	body.player_states.call_deferred("set_state", "death")
	queue_free()
