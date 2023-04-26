extends Node2D

signal reached_waypoint
signal finished_waypoint
signal dialog_finished

export(bool) var lock_height := true
export(bool) var autoplay := false
export(Color) var dialog_color: Color
export(float) var move_speed := 80.0
export(float) var follow_dist := 24.0
export(NodePath) var waypoints_path: NodePath setget set_waypoints_path
export(Array, Array, String, MULTILINE) var autoplay_dialog: Array setget \
		set_autoplay_dialog

var target: Vector2
var moving := false
var autoplay_ind := 0
var autoplaying := false

var following := false
var follow_target: Node2D

onready var waypoints: Node
onready var anim_sprite := $Pivot/AnimatedSprite
onready var pivot := $Pivot
onready var dialog_player := $C/DialogPlayer


func _ready() -> void:
	if waypoints_path:
		waypoints = get_node(waypoints_path)
		if waypoints.has_start_point():
			if lock_height:
				position.x = waypoints.get_start_point().x
			else:
				position = waypoints.get_start_point()
	dialog_player.default_color = dialog_color
	if autoplay:
		autoplay()


func _physics_process(delta: float) -> void:
	if following:
		set_facing(follow_target.position.x - position.x)
		if lock_height:
			if abs(position.x - follow_target.position.x) >= follow_dist:
				position.x += move_speed * delta * \
						sign(follow_target.position.x - position.x)
		else:
			if position.distance_squared_to(follow_target.position) >= \
					pow(follow_dist, 2):
				position += position.direction_to(follow_target.position) * \
						move_speed * delta
	if moving:
		var move_amount := move_speed * delta
		if lock_height:
			if abs(position.x - target.x) <= move_amount:
				position.x = target.x
				reached_waypoint()
			else:
				position.x += move_amount * sign(target.x - position.x)
		else:
			if position.distance_squared_to(target) <= pow(move_amount, 2):
				position = target
				reached_waypoint()
			else:
				position += position.direction_to(target) * move_amount


func flip() -> void:
	pivot.scale.x *= -1


func set_facing(input: int) -> void:
	if sign(pivot.scale.x) != sign(input):
		flip()


func read(dialog: Array) -> void:
	anim_sprite.play("talk")
	dialog_player.read(dialog)


func set_waypoints_path(val: NodePath) -> void:
	waypoints_path = val
	if is_inside_tree():
		waypoints = get_node(waypoints_path)


func set_autoplay_dialog(val: Array) -> void:
	autoplay_dialog = val
	autoplay_ind = 0


func autoplay() -> void:
	autoplaying = true
	yield(read_autoplay_dialog(), "completed")
	goto_next()


func goto_next() -> void:
	target = waypoints.get_next_point()
	set_facing(target.x - position.x)
	moving = true
	anim_sprite.play("walk")


func goto_pos(pos: Vector2) -> void:
	set_facing(pos.x - position.x)
	moving = true
	anim_sprite.play("walk")
	target = pos


func reached_waypoint() -> void:
	moving = false
	anim_sprite.play("idle")
	if waypoints:
		if waypoints.has_next_point():
			if autoplaying:
				yield(read_autoplay_dialog(), "completed")
				emit_signal("reached_waypoint")
				goto_next()
			else:
				emit_signal("reached_waypoint")
		else:
			if autoplaying:
				yield(read_autoplay_dialog(), "completed")
				autoplaying = false
			emit_signal("reached_waypoint")
			emit_signal("finished_waypoint")
	else:
		emit_signal("reached_waypoint")


func read_autoplay_dialog() -> void:
	if len(autoplay_dialog) > autoplay_ind and autoplay_dialog[autoplay_ind]:
		anim_sprite.play("talk")
		dialog_player.read(autoplay_dialog[autoplay_ind])
		autoplay_ind += 1
		yield(dialog_player, "dialog_finished")
	else:
		autoplay_ind += 1
		yield(get_tree(), "idle_frame")


func _on_DialogPlayer_dialog_finished() -> void:
	anim_sprite.play("idle")
	emit_signal("dialog_finished")
