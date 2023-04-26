extends Line2D

var from_point: Vector2 = Vector2()
var to_point: Vector2 = Vector2.ONE * 90
var dur := 0.18


func _ready() -> void:
	points = PoolVector2Array([from_point, to_point])
	var t := create_tween()
	t.tween_method(self, "tween_pos", from_point, to_point, dur)
	yield(t, "finished")
	queue_free()


func tween_pos(pos: Vector2) -> void:
	set_point_position(0, pos)
