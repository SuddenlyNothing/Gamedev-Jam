extends Node2D

signal switched_scene

onready var bg1 := $Bg1
onready var bg2 := $BackBufferCopy/Bg2
onready var mask := $BackBufferCopy/Mask

var t: SceneTreeTween
var is_past := false

var locked := false setget set_locked


func _ready() -> void:
	get_tree().call_group("past", "set_past", false)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("warp") and \
			(not t or not t.is_running()) and not locked:
		toggle_scene()


func set_locked(val: bool) -> void:
	locked = val


func toggle_scene() -> void:
	emit_signal("switched_scene")
	if t:
		t.kill()
	var canvas = get_canvas_transform()
	var topleft = -canvas.origin / canvas.get_scale()
	var size = get_viewport_rect().size / canvas.get_scale()
	mask.position = topleft + size / 2
	if is_past:
		get_tree().call_group("past", "set_past", false)
	else:
		get_tree().call_group("present", "set_present", false)
	t = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	t.tween_callback(mask, "show")
	t.tween_property(mask, "scale", Vector2.ONE * 3, 0.3).from(Vector2.ZERO)
	t.tween_callback(self, "switch_children")
	t.tween_callback(mask, "hide")
	if is_past:
		t.tween_callback(get_tree(), "call_group", ["present", "set_present", true])
	else:
		t.tween_callback(get_tree(), "call_group", ["past", "set_past", true])
	is_past = not is_past


func toggle_scene_no_anim() -> void:
	switch_children()
	if is_past:
		get_tree().call_group("past", "set_past", false)
		get_tree().call_group("present", "set_present", true)
	else:
		get_tree().call_group("present", "set_present", false)
		get_tree().call_group("past", "set_past", true)
	is_past = not is_past


func switch_children() -> void:
	var c1 = bg1.get_child(0)
	bg1.remove_child(c1)
	var c2 = bg2.get_child(0)
	bg2.remove_child(c2)
	bg1.add_child(c2)
	bg2.add_child(c1)


func get_past() -> Node:
	if is_past:
		return bg2.get_child(0)
	else:
		return bg1.get_child(0)


func get_present() -> Node:
	if is_past:
		return bg1.get_child(0)
	else:
		return bg2.get_child(0)
