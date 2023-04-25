extends StaticBody2D

var is_inside := false

onready var original_pos := Vector2() setget set_original_pos
onready var collision := $CollisionShape2D


func set_present(present: bool) -> void:
	yield(get_tree(), "idle_frame")
	collision.disabled = not present


func set_past(past: bool) -> void:
	if past:
		position = original_pos
	else:
		var player: Node = get_tree().get_nodes_in_group("player")[0]
		var player_right = player.position.x + player.collision.shape.extents.x
		var player_left = player.position.x - player.collision.shape.extents.x
		if (player_right > position.x and player_right < \
				position.x + collision.shape.extents.x * 2) or\
				(player_left > position.x and \
				player_left < position.x + collision.shape.extents.x * 2):
			position.x = player_right


func set_original_pos(pos: Vector2) -> void:
	original_pos = pos
	position = original_pos
