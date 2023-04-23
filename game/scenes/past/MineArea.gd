extends Area2D

const GoldOre := preload("res://scenes/past/GoldOre.tscn")

onready var collision_shape := $CollisionShape2D


func _ready() -> void:
	spawn_ore()
	spawn_ore()
	spawn_ore()


func spawn_ore() -> void:
	var gold_ore := GoldOre.instance()
	gold_ore.position = Vector2((randf() - 0.5) * 2 * \
			collision_shape.shape.extents.x, 0)
	gold_ore.connect("collected", self, "spawn_ore")
	add_child(gold_ore)


func _on_MineArea_body_entered(body: Node) -> void:
	body.set_mining(true)


func _on_MineArea_body_exited(body: Node) -> void:
	body.set_mining(false)
