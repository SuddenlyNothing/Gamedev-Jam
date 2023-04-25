extends Control

var t: SceneTreeTween

onready var label := $Label


func display(words: String) -> void:
	label.text = words
	show()
	if t:
		t.kill()
	var rect := get_viewport_rect()
	t = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	t.tween_property(label, "rect_position:y",
			rect.size.y / 2 - label.rect_size.y, 1.0).from(rect.size.y)
	t.tween_property(label, "rect_position:y", -label.rect_size.y, 1.0)\
			.set_ease(Tween.EASE_IN)
	t.tween_callback(self, "hide")
