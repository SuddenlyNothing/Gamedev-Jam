extends Node

# Used for input remapping and control displays
var user_keys := PoolStringArray([
	"pause",
	"interact",
	"time_travel",
	"left",
	"right"
])

# Used for formatting strings to display the correct key.
var input_format := {}
