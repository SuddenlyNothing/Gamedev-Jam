extends Area2D

const GRAVITY := 400.0

var target: Node2D
var offset: Vector2

var velocity := Vector2((randf() - 0.5) * 100.0, -200.0)
var connected := false

onready var ground := position.y
onready var collect_sfx := $CollectSFX
onready var collision_shape := $CollisionShape2D


func _process(delta: float) -> void:
	velocity.y += GRAVITY * delta
	if not connected and velocity.y > 0:
		collision_shape.call_deferred("set_disabled", false)
		connected = true
	
	var move_amount := velocity * delta
	position += velocity * delta
	if move_amount.y + position.y > ground:
		set_process(false)
		position.y = ground


func set_past(past: bool) -> void:
	if connected:
		collision_shape.call_deferred("set_disabled", not past)
	set_process(past)


func _on_Gold_body_entered(body: Node2D) -> void:
	self.disconnect("body_entered", self, "_on_Gold_body_entered")
	target = body
	set_process(false)
	offset = global_position + (Vector2.RIGHT * 50).rotated(randf() * 2 * PI)
	var t := create_tween().set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN)
	t.tween_method(self, "move_collect", 0.0, 1.0, 0.4)
	t.tween_callback(self, "hide")
	t.tween_callback(collect_sfx, "play")


func move_collect(weight: float) -> void:
	global_position = lerp(global_position, target.global_position, weight)


func _on_CollectSFX_finished() -> void:
	queue_free()
