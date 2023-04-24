extends Node2D

enum Prices {
	GUN = 10,
	SHIELD = 25,
	SCISSOR = 5,
}

var player: Node
var item: String

var p_gun := false
var p_shield := false
var p_scissor := false

onready var price_thought := $PriceThought
onready var gold_count := $PriceThought/Price/GoldCount
onready var thought := $PriceThought/Thought
onready var price := $PriceThought/Price
onready var collisions := [
	$Gun/CollisionShape2D,
	$Shield/CollisionShape2D,
	$Scissor/CollisionShape2D
]
onready var purchased := [
	$Purchased,
	$Purchased2,
	$Purchased3
]


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and item and \
			player.gold >= Prices[item]:
		player.sell_gold(Prices[item])
		match item:
			"GUN":
				purchased[0].show()
				p_gun = true
				player.gun = true
			"SHIELD":
				purchased[1].show()
				p_shield = true
				player.shield = true
			"SCISSOR":
				purchased[2].show()
				p_scissor = true
				player.scissor = true
		item = ""
		price_thought.hide()


func set_present(present: bool) -> void:
	set_process_input(present)
	for collision in collisions:
		collision.call_deferred("set_disabled", not present)


func show_price() -> void:
	price.hide()
	price_thought.show()
	thought.frame = 0
	thought.play("default")
	gold_count.text = str(Prices[item])


func _on_Gun_body_entered(body: Node) -> void:
	if p_gun:
		return
	player = body
	item = "GUN"
	show_price()


func _on_Shield_body_entered(body: Node) -> void:
	if p_shield:
		return
	player = body
	item = "SHIELD"
	show_price()


func _on_Scissor_body_entered(body: Node) -> void:
	if p_scissor:
		return
	player = body
	item = "SCISSOR"
	show_price()


func _on_body_exited(body: Node) -> void:
	price_thought.hide()
	item = ""


func _on_Thought_frame_changed() -> void:
	if thought.frame == 2:
		price.show()
