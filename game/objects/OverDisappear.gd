extends Node2D

export(bool) var is_present := true

var t: SceneTreeTween


func _ready() -> void:
	add_to_group("past")
	add_to_group("present")


func set_past(past: bool) -> void:
#	if not is_present:
#		if past:
#			fade_in()
#		else:
#			fade_out()
	
#	if not is_present:
#		if past:
#			fade_in()
#		else:
#			fade_out()
	
	if is_present and not past:
		fade_in()
	elif not past:
		fade_out()


func set_present(present: bool) -> void:
#	if is_present:
#		if present:
#			fade_in()
#		else:
#			fade_out()
#	if is_present:
#		if present:
#			fade_in()
#		else:
#			fade_out()
	
	if is_present and not present:
		fade_out()
	elif not present:
		fade_in()


func fade_out() -> void:
#	z_index = 0
	t = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	t.tween_property(self, "modulate:a", 0.0, 0.3)


func fade_in() -> void:
	if t:
		t.kill()
	z_index = 100
	self.modulate.a = 1
#	var t := create_tween()
#	t.tween_property(self, "modulate:a", 1.0, 0.3)
