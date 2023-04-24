extends Camera2D

var t: SceneTreeTween


func set_focus(node: Node2D, offset: Vector2 = Vector2()) -> void:
	if t:
		t.kill()
	t = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	t.tween_property(self, "position", offset, 0.5)\
			.from(global_position - node.position)
	get_parent().remove_child(self)
	node.call_deferred("add_child", self)
