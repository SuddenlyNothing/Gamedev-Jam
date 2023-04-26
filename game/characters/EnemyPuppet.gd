extends "res://characters/CharacterPuppet.gd"

const BulletLine := preload("res://objects/BulletLine.tscn")

export(bool) var start_left := false

var kidnap := false setget set_kidnap

onready var bullet_pos := $Pivot/Gun/BulletPos
onready var gun := $Pivot/Gun
onready var gun_sfx := $GunSFX


func _ready() -> void:
	if start_left:
		set_facing(-1)


func set_kidnap(val: bool) -> void:
	kidnap = val
	if kidnap:
		play_anim(anim_sprite.animation)


func play_anim(anim: String) -> void:
	gun.hide()
	if kidnap:
		anim = "kidnap_" + anim
	.play_anim(anim)


func shoot(pos: Vector2) -> void:
	var bullet_line := BulletLine.instance()
	bullet_line.from_point = bullet_pos.global_position
	bullet_line.to_point = pos
	get_parent().add_child(bullet_line)
	gun.show()
	gun.playing = true
	gun.frame = 0
	gun_sfx.play()
