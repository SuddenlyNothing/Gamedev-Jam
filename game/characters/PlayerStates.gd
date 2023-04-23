extends StateMachine


func _ready() -> void:
	add_state("idle")
	add_state("walk")
	add_state("mine")
	add_state("cut")
	call_deferred("set_state", "idle")


# Contains state logic.
func _state_logic(delta: float) -> void:
	match state:
		states.idle:
			pass
		states.walk:
			parent.move(delta)
		states.mine:
			parent.mine_move(delta)


# Return value will be used to change state.
func _get_transition(delta: float):
	match state:
		states.idle:
			if parent.mining:
				return states.mine
			if parent.input != 0:
				return states.walk
		states.walk:
			if parent.mining:
				return states.mine
			if parent.velocity == 0:
				return states.idle
		states.mine:
			if not parent.mining:
				return states.walk
	return null


# Called on entering state.
# new_state is the state being entered.
# old_state is the state being exited.
func _enter_state(new_state: String, old_state) -> void:
	pass


# Called on exiting state.
# old_state is the state being exited.
# new_state is the state being entered.
func _exit_state(old_state, new_state: String) -> void:
	pass
