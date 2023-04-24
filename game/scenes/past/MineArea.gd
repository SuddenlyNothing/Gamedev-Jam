extends Area2D

const GoldOre := preload("res://scenes/past/GoldOre.tscn")

onready var collision_shape := $CollisionShape2D


func _ready() -> void:
	spawn_ore()
	spawn_ore()
	spawn_ore()


func set_past(past: bool) -> void:
	collision_shape.call_deferred("set_disabled", not past)


func spawn_ore() -> void:
	var gold_ore := GoldOre.instance()
	gold_ore.position = Vector2((randf() - 0.5) * 2 * \
			(collision_shape.shape.extents.x - 20), 0)
	gold_ore.connect("collected", self, "spawn_ore")
	add_child(gold_ore)


func _on_MineArea_body_entered(body: Node) -> void:
	body.set_mining(true)
	get_tree().call_group("global_camera", "set_focus", self, Vector2.UP * 8)


func _on_MineArea_body_exited(body: Node) -> void:
	body.set_mining(false)
	get_tree().call_group("global_camera", "set_focus", body)
