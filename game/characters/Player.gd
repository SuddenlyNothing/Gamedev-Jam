extends KinematicBody2D

export(float) var walk_acceleration := 300.0
export(float) var walk_max_speed := 80.0
export(float) var walk_friction := 1200.0
export(float) var walk_turn_mult := 3.0

export(float) var mine_acceleration := 100.0
export(float) var mine_max_speed := 250.0
export(float) var mine_friction := 50.0
export(float) var mine_turn_mult := 1.0

var input := 0
var velocity: float = 0.0
var mining := false

onready var player_states := $PlayerStates


func _process(delta: float) -> void:
	get_input()


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
