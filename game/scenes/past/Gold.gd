extends Area2D

const GRAVITY := 400.0
const GOLD_POS := Vector2(27, 17)

var pickup_pos: Vector2
var offset: Vector2

var velocity := Vector2((randf() - 0.5) * 100.0, -200.0)
var connected := false
var player: Node2D

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
	player = body
	pickup_pos = global_position
	offset = global_position + (Vector2.RIGHT * 200).rotated(randf() * 2 * PI)
	set_process(false)
	var t := create_tween().set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN_OUT)
	t.tween_method(self, "move_collect", 0.0, 1.0, 0.6)
	t.tween_callback(self, "hide")
	t.tween_callback(player, "collect_gold")
	t.tween_callback(collect_sfx, "play")


func move_collect(weight: float) -> void:
	var canvas = get_canvas_transform()
	var topleft = -canvas.origin / canvas.get_scale()
	global_position = lerp(pickup_pos,
			lerp(offset, topleft + GOLD_POS / canvas.get_scale(), weight),
			weight)


func _on_CollectSFX_finished() -> void:
	queue_free()
