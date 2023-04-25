extends Area2D

const GoldOre := preload("res://scenes/past/GoldOre.tscn")

export(int) var max_gold := 5 setget set_max_gold
export(int) var num_field_gold := 3

var spawned_gold := 0
var collected_gold := 0

onready var collision_shape := $CollisionShape2D


func _ready() -> void:
	for i in num_field_gold:
		spawn_ore()


func set_max_gold(val: int) -> void:
	max_gold = val
	if max_gold > spawned_gold:
		for i in (num_field_gold - (spawned_gold - collected_gold)):
			spawn_ore()


func set_past(past: bool) -> void:
	collision_shape.call_deferred("set_disabled", not past)


func spawn_ore() -> void:
	if spawned_gold >= max_gold:
		return
	var gold_ore := GoldOre.instance()
	gold_ore.position = Vector2((randf() - 0.5) * 2 * \
			(collision_shape.shape.extents.x - 20), 0)
	gold_ore.connect("collected", self, "respawn_ore")
	add_child(gold_ore)
	spawned_gold += 1


func respawn_ore() -> void:
	collected_gold += 1
	spawn_ore()


func _on_MineArea_body_entered(body: Node) -> void:
	body.set_mining(true)
	get_tree().call_group("global_camera", "set_focus", self, Vector2.UP * 8)


func _on_MineArea_body_exited(body: Node) -> void:
	body.set_mining(false)
	get_tree().call_group("global_camera", "set_focus", body)
