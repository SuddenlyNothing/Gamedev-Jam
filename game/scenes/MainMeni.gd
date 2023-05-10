extends Control


func _ready() -> void:
	Variables.intro_cutscene = false
	Variables.first_puzzle = false


func _on_Settings_pressed() -> void:
	OptionsMenu.set_active(true)
