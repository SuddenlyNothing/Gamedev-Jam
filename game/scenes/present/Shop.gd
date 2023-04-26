extends Node2D

enum Inds {
	GUN = 0,
	SHIELD = 1,
	SCISSOR = 2,
}

enum Prices {
	GUN = 10,
	SHIELD = 25,
	SCISSOR = 5,
}

var player: Node
var item: String
var t: SceneTreeTween

onready var purchased_sfx := $PurchaseSFX
onready var collisions := [
	$Gun/CollisionShape2D,
	$Shield/CollisionShape2D,
	$Scissor/CollisionShape2D
]
onready var purchased := [
	$Purchased,
	$Purchased2,
	$Purchased3,
]
onready var areas := [
	$Gun,
	$Shield,
	$Scissor,
]
onready var labels := [
	$"Items/GunSell/10",
	$"Items/ShieldSell/25",
	$"Items/ScissorSell/5",
]
onready var sprites := [
	$Items/GunSell,
	$Items/ShieldSell,
	$Items/ScissorSell,
]


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and item and \
			player.gold >= Prices[item]:
		player.sell_gold(Prices[item])
		purchased_sfx.play()
		match item:
			"GUN":
				player.gun = true
			"SHIELD":
				player.shield = true
			"SCISSOR":
				player.scissor = true
		var ind: int = Inds[item]
		collisions[ind].call_deferred("set_disabled", true)
		sprites[ind].self_modulate.a = 0
		purchased[ind].show()
		item = ""


func set_present(present: bool) -> void:
	set_process_input(present)
	for i in len(collisions):
		collisions[i].call_deferred("set_disabled",
				not present or purchased[i].visible)


func show_price() -> void:
	var ind: int = Inds[item]
	for i in 3:
		if i == ind:
			labels[i].modulate = Color("f2efdf")
			if t:
				t.kill()
			t = create_tween().set_loops().set_ease(Tween.EASE_IN_OUT)\
					.set_trans(Tween.TRANS_QUAD)
			t.tween_property(sprites[i], "offset:y", -4, 0.6)
			t.tween_property(sprites[i], "offset:y", -2, 0.6)
		else:
			labels[i].modulate = Color("000")
			var ot := create_tween().set_ease(Tween.EASE_IN_OUT)\
					.set_trans(Tween.TRANS_QUAD)
			ot.tween_property(sprites[i], "offset:y", 0, 0.1)


func _on_Gun_body_entered(body: Node) -> void:
	if item == "GUN":
		return
	player = body
	item = "GUN"
	show_price()


func _on_Shield_body_entered(body: Node) -> void:
	if item == "SHIELD":
		return
	player = body
	item = "SHIELD"
	show_price()


func _on_Scissor_body_entered(body: Node) -> void:
	if item == "SCISSOR":
		return
	player = body
	item = "SCISSOR"
	show_price()


func _on_body_exited(body: Node) -> void:
	for area in areas:
		if area.get_overlapping_bodies():
			area.emit_signal("body_entered", body)
			return
	t.kill()
	for i in 3:
		labels[i].modulate = Color("000")
		var ot := create_tween().set_ease(Tween.EASE_IN)\
				.set_trans(Tween.TRANS_QUAD)
		ot.tween_property(sprites[i], "offset:y", 0, 0.1)
	item = ""
