extends "res://characters/CharacterPuppet.gd"

export(float) var lock_spot

var player: Node2D
var charge_dist = 60

onready var collision := $Area2D/CollisionShape2D
onready var charge_wait := $ChargeWait


func start(p: Node2D) -> void:
	player = p
	attack()


func attack() -> void:
	collision.call_deferred("set_disabled", false)
	goto_pos(position.direction_to(player.position) * charge_dist)
	yield(self, "reached_waypoint")
	charge_wait.start()
	collision.call_deferred("set_disabled", true)


func set_past(past: bool) -> void:
	if moving:
		collision.call_deferred("set_disabled", not past)
	anim_sprite.playing = past
	set_physics_process(past)


func _on_Area2D_body_entered(body: Node) -> void:
	body.set_locked(true)
	get_tree().call_group("scene_switcher", "set_locked", true)
	body.kill()


func _on_ChargeWait_timeout() -> void:
	attack()
