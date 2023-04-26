extends "res://characters/CharacterPuppet.gd"

var kidnap := false setget set_kidnap


func set_kidnap(val: bool) -> void:
	kidnap = val
	if kidnap:
		play_anim(anim_sprite.animation)


func play_anim(anim: String) -> void:
	if kidnap:
		anim = "kidnap_" + anim
	.play_anim(anim)
