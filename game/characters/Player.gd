extends KinematicBody2D

signal collected_gold(amt)
signal dialog_finished

export(float) var walk_acceleration := 300.0
export(float) var walk_max_speed := 80.0
export(float) var walk_friction := 1200.0
export(float) var walk_turn_mult := 3.0

export(float) var mine_acceleration := 300.0
export(float) var mine_max_speed := 1000.0
export(float) var mine_friction := 50.0
export(float) var mine_turn_mult := 0.8

var input := 0
var velocity: float = 0.0
var mining := false
var gold := 0
var locked := false setget set_locked

var going := false
var target: float

var gun := false setget set_gun
var shield := false setget set_shield
var scissor := false setget set_scissor

onready var player_states := $PlayerStates
onready var anim_sprite := $Pivot/AnimatedSprite
onready var gold_count := $C/HUD/M/H/GoldCount
onready var dialog_player := $C/DialogPlayer
onready var gold_icon := $C/HUD/M/H/GoldIcon
onready var pivot := $Pivot
onready var gold_icon_pos: Vector2 = gold_icon.rect_position
onready var collision := $CollisionShape2D
onready var fade := $C/Fade
onready var hud := $C/HUD


func _process(delta: float) -> void:
	if locked:
		return
	get_input()


func _physics_process(delta: float) -> void:
	if going:
		var move_amount := walk_max_speed * delta
		if abs(position.x - target) <= move_amount:
			position.x = target
		else:
			position.x += move_amount * sign(target - position.x)


func kill() -> void:
	player_states.call_deferred("set_state", "death")


func set_locked(val: bool) -> void:
	locked = val
	if locked:
		input = 0
		velocity = 0


func read(dialog: Array) -> void:
	play_anim("talk")
	dialog_player.read(dialog)


func goto_pos(x: float) -> void:
	set_facing(x - position.x)
	target = x
	going = true


func set_facing(input: int) -> void:
	if sign(pivot.scale.x) != sign(input):
		pivot.scale.x *= -1


func set_gun(val: bool) -> void:
	dialog_player.read([
		"Press {interact} to shoot."
	])


func set_shield(val: bool) -> void:
	dialog_player.read([
		"Bullets no longer hurt."
	])


func set_scissor(val: bool) -> void:
	dialog_player.read([
		"Scissor beats paper..."
	])


func collect_gold() -> void:
	gold += 1
	gold_count.text = str(gold)
	var t := create_tween().set_ease(Tween.EASE_OUT)\
			.set_trans(Tween.TRANS_QUAD)
	t.tween_property(gold_icon, "rect_position:y",
			gold_icon_pos.y, 0.2)\
			.from(gold_icon_pos.y - 5)
	emit_signal("collected_gold", gold)


func sell_gold(amt: int) -> void:
	gold -= amt
	gold_count.text = str(gold)


func set_gold(amt: int) -> void:
	hud.show()
	gold = amt
	gold_count.text = str(amt)


func get_input() -> void:
	input = Input.get_action_strength("right") - \
			Input.get_action_strength("left")


func mine_move(delta: float) -> void:
	move(delta, mine_acceleration, mine_max_speed,
			mine_friction, mine_turn_mult)


func move(delta: float,
		acceleration: float = walk_acceleration,
		max_speed: float = walk_max_speed,
		friction: float = walk_friction,
		turn_mult: float = walk_turn_mult) -> void:
	if input:
		set_facing(input)
		apply_acceleration(delta, acceleration, max_speed, turn_mult)
	else:
		apply_friction(delta, friction)
	move_and_collide(Vector2(velocity * delta, 0))


func apply_acceleration(delta: float, acceleration: float,
		max_speed: float, turn_mult: float) -> void:
	var acceleration_amount := acceleration * delta * input
	if abs(velocity + acceleration_amount) >= max_speed:
		velocity = max_speed * sign(acceleration_amount)
	else:
		var sign_vel = sign(velocity)
		if sign_vel != sign(acceleration_amount) and sign_vel != 0:
			acceleration_amount *= turn_mult
		velocity += acceleration_amount


func apply_friction(delta: float, friction: float) -> void:
	var friction_amount := friction * delta
	if abs(velocity) <= friction_amount:
		velocity = 0
	else:
		velocity -= friction_amount * sign(velocity)


func set_mining(val: bool) -> void:
	mining = val


func play_anim(anim: String) -> void:
	anim_sprite.play(anim)


func disable_collisions() -> void:
	collision.call_deferred("set_disabled", true)


func die() -> void:
	fade.show()
	set_locked(true)
	get_tree().call_group("global_camera", "set_focus", self)
	get_tree().call_group("scene_switcher", "set_locked", true)
	disable_collisions()
	var t := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	t.tween_property(fade, "modulate:a", 1.0, 1.5)
	yield(t, "finished")
	SceneHandler.restart_scene()


func _on_DialogPlayer_dialog_finished() -> void:
	anim_sprite.play("idle")
	emit_signal("dialog_finished")
	fade.show()
