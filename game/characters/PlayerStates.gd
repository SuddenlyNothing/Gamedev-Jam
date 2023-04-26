extends StateMachine

var died := false

onready var mine_sfx := $MineSFX


func _ready() -> void:
	add_state("idle")
	add_state("walk")
	add_state("mine")
	add_state("cut")
	add_state("death")
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
	match new_state:
		states.idle:
			parent.play_anim("idle")
		states.walk:
			parent.play_anim("walk")
		states.mine:
			parent.play_anim("mine")
			mine_sfx.play()
		states.death:
			parent.play_anim("death")
			parent.die()


# Called on exiting state.
# old_state is the state being exited.
# new_state is the state being entered.
func _exit_state(old_state, new_state: String) -> void:
	match old_state:
		states.idle:
			pass
		states.walk:
			pass
		states.mine:
			mine_sfx.stop()


# Sets state while calling _exit_state and _enter_state
# If you want to call this method use call_deferred.
func set_state(new_state: String) -> void:
	if died:
		return
	if new_state == states.death:
		died = true
	.set_state(new_state)
