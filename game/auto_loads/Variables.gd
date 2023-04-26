extends Node

# Used for input remapping and control displays
var user_keys := PoolStringArray([
	"pause",
	"interact",
	"warp",
	"left",
	"right"
])

# Used for formatting strings to display the correct key.
var input_format := {}

var intro_cutscene := false
var player_x_pos := 550
