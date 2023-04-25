extends Camera2D

var t: SceneTreeTween
var zt: SceneTreeTween

onready var previous_offset := position
onready var previous_focus := get_parent()


func set_focus(node: Node2D, offset: Vector2 = Vector2()) -> void:
	previous_focus = get_parent()
	previous_offset = position
	if t:
		t.kill()
	t = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	t.tween_property(self, "position", offset, 0.5)\
			.from(global_position - node.position)
	get_parent().remove_child(self)
	node.call_deferred("add_child", self)


func return_focus() -> void:
	set_focus(previous_focus, previous_offset)


func set_zoom(val: Vector2, dur: float = 0.5) -> void:
	if zt:
		zt.kill()
	zt = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	zt.tween_property(self, "zoom", val, dur)
