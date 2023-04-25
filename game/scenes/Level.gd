extends Node2D

const PropBullet := preload("res://objects/PropBullet.tscn")

onready var player := $Player
onready var friend := $Friend
onready var scientist := $Scientist
onready var scene_switcher := $SceneSwitcher
onready var appear := $Scientist/Appear
onready var mine_found_collision := $MineFound/CollisionShape2D
onready var banner := $C/Banner
onready var friend_final_pos := $Waypoints/FriendFinalPos
onready var prop_gun := $PropGun
onready var bullet_pos := $PropGun/BulletPos
onready var dialog_player := $C/DialogPlayer

onready var enemies := [
	$EnemyLeader, $Enemy, $Enemy2
]


func _ready() -> void:
	yield(get_tree(), "idle_frame")
	player.set_locked(true)
	scene_switcher.set_locked(true)
	if not Variables.intro_cutscene:
		player.set_facing(-1)
		player.read([
			"I wish I wasn't so [shake]poor[/shake]",
			"If I was rich, I would be able to buy all this [wave]cool stuff",
		])
		yield(player, "dialog_finished")
		friend.goto_next()
		yield(friend, "reached_waypoint")
		friend.read([
			"You should stop looking at the shop front",
			"It'll only make you more upset",
		])
		yield(friend, "dialog_finished")
		player.set_facing(1)
		player.read([
			"I just need to think of a get rich quick scheme",
			"[shake]Damn it!![/shake] If only I was alive during the gold rush, "+
					"I'd be able to live a life of comfort and satisfaction"
		])
		yield(player, "dialog_finished")
		scientist.show()
		appear.emitting = true
		scientist.flip()
		friend.flip()
		scientist.read([
			"Did you mean that?"
		])
		yield(scientist, "dialog_finished")
		player.read([
			"Aaghh!",
			"Where'd you come from?"
		])
		yield(player, "dialog_finished")
		friend.read([
			"Are you the devil?",
		])
		yield(friend, "dialog_finished")
		scientist.read([
			"No, of course not.",
			"I'm just your friendly neighborhood scientist",
			"How would you like to tes-- use my new [color=white][rainbow]time travel device[/rainbow][/color]?"
		])
		yield(scientist, "dialog_finished")
		friend.read([
			"That seems a little..."
		])
		yield(friend, "dialog_finished")
		player.read([
			"[shake]YES![/shake] Mmhmm... Of course Mr. Scientist, I will graciously accept your offer"
		])
		yield(player, "dialog_finished")
		scientist.read([
			"Then I will just quickly attach it"
		])
		yield(scientist, "dialog_finished")
		scientist.goto_next()
		yield(scientist, "reached_waypoint")
		yield(get_tree().create_timer(0.5, false), "timeout")
		scientist.goto_next()
		yield(scientist, "finished_waypoint")
		scientist.flip()
		scientist.read([
			"And now you should be able to..."
		])
		yield(scientist, "dialog_finished")
	else:
		scientist.show()
		friend.position.x = friend_final_pos.position.x
	
	Variables.intro_cutscene = true
	
	remove_child(scientist)
	scene_switcher.get_present().add_child(scientist)
	scene_switcher.toggle_scene()
	yield(get_tree().create_timer(1.0, false), "timeout")
	friend.read([
		"Whoa that actually worked!",
		"We're really in the past",
	])
	yield(friend, "dialog_finished")
	player.read([
		"Let's go find ourselves some gold",
	])
	yield(player, "dialog_finished")
	dialog_player.read([
		"Use {left} and {right} to move",
	])
	yield(dialog_player, "dialog_finished")
	player.set_locked(false)
	friend.following = true
	friend.follow_target = player


func _on_MineFound_body_entered(body: Node) -> void:
	mine_found_collision.call_deferred("set_disabled", true)
	player.set_locked(true)
	yield(get_tree(), "idle_frame")
	player.read([
		"This must be the mine",
		"I can practically smell the gold from here"
	])
	yield(player, "dialog_finished")
	player.set_locked(false)
	banner.display("Mine 5 Gold")


func _on_Player_collected_gold(amt: int) -> void:
	if amt != 5:
		return
	player.set_locked(true)
	player.set_facing(1)
	get_tree().call_group("global_camera", "set_focus", player)
	player.read([
		"Wow! This is so easy. It's like taking candy from a baby",
	])
	yield(player, "dialog_finished")
	get_tree().call_group("global_camera", "set_focus", enemies[0],
			Vector2.UP * 8)
	var start: float = player.position.x + get_viewport_rect().size.x + 16
	for i in len(enemies):
		enemies[i].show()
		enemies[i].position.x = start + 32 * i
		enemies[i].set_facing(-1)
	enemies[1].following = true
	enemies[1].follow_target = enemies[0]
	enemies[1].follow_dist = 64
	enemies[2].following = true
	enemies[2].follow_target = enemies[1]
	enemies[0].read([
		"What in tarnation are y'all doin' on our land?",
		"Y'all are rustlin' our gold!"
	])
	yield(enemies[0], "dialog_finished")
	get_tree().call_group("global_camera", "set_focus", player,
			Vector2.RIGHT * 64)
	enemies[0].goto_pos(
		Vector2(max(player.position.x, friend.position.x) + 128, 0)
	)
	player.read([
		"Your gold? We mined it fair and square"
	])
	yield(player, "dialog_finished")
	if enemies[0].moving:
		yield(enemies[0], "reached_waypoint")
	
	enemies[0].read([
		"Stealin' gold is a dang serious crime",
		"If y'all don't want to lose a limb, hand it over"
	])
	yield(enemies[0], "dialog_finished")
	friend.read([
		"Maybe we should give it back..."
	])
	yield(friend, "dialog_finished")
	player.read([
		"No! If you want it, you'll have to take it"
	])
	yield(player, "dialog_finished")
	enemies[0].read([
		"Fine. Y'all can keep the gold, but in exchange, we're takin' your pal"
	])
	yield(enemies[0], "dialog_finished")
	enemies[1].following = false
	enemies[2].following = false
	var pos: Vector2 = enemies[1].position
	enemies[1].goto_pos(friend.position + Vector2.RIGHT * 8)
	yield(enemies[1], "reached_waypoint")
	friend.follow_target = enemies[1]
	friend.follow_dist = 8
	yield(get_tree().create_timer(0.5, false), "timeout")
	enemies[1].goto_pos(pos)
	yield(enemies[1], "reached_waypoint")
	enemies[1].set_facing(-1)
	prop_gun.position = enemies[0].position + Vector2(-4, -8)
	prop_gun.show()
	enemies[0].read([
		"And, as a little parting gift, here's some lead"
	])
	yield(enemies[0], "dialog_finished")
	var past: Node = scene_switcher.get_past()
	var prop_bullet := PropBullet.instance()
	remove_child(prop_gun)
	past.add_child(prop_gun)
	prop_bullet.position = bullet_pos.global_position
	prop_bullet.stop_point = player.position.x + 16
	past.add_child(prop_bullet)
	yield(get_tree().create_timer(1.0, false), "timeout")
	scene_switcher.set_locked(false)
	dialog_player.read([
		"Press {time_travel} to time travel"
	])
	enemies[1].following = true
	enemies[2].following = true
	remove_child(friend)
	past.add_child(friend)
	for enemy in enemies:
		remove_child(enemy)
		past.add_child(enemy)
	yield(scene_switcher, "switched_scene")
	dialog_player.stop()
#	scene_switcher.set_locked(true)
