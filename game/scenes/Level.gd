extends Node2D

const PropBullet := preload("res://objects/PropBullet.tscn")
const BulletLine := preload("res://objects/BulletLine.tscn")

export(String, FILE, "*.tscn") var menu_scene

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
onready var rock := $Rock
onready var prevent_skip_collision := $PreventSkip/CollisionShape2D
onready var shot_sfx := $ShotSFX

onready var enemies := [
	$EnemyLeader, $Enemy, $Enemy2
]


func _ready() -> void:
	scene_switcher.get_past().connect("won", self, "_on_won")
	yield(get_tree(), "idle_frame")
	player.set_locked(true)
	scene_switcher.set_locked(true)
	if Variables.first_puzzle:
		scene_switcher.toggle_scene_no_anim()
		# Mine
		mine_found_collision.call_deferred("set_disabled", true)
		
		# Player
		player.position.x = Variables.player_x_pos
		
		# Friend
		remove_child(friend)
		scene_switcher.get_past().add_child(friend)
		friend.hide()
		
		# Enemies
		for enemy in enemies:
			enemy.show()
			enemy.set_facing(-1)
		enemies[0].position.x = player.position.x + 32
		enemies[1].kidnap = true
		enemies[1].position.x = player.position.x + 64
		enemies[2].position.x = player.position.x + 96
		enemies[1].follow_target = enemies[0]
		enemies[1].follow_dist = 32
		enemies[2].follow_target = enemies[1]
		enemies[1].following = true
		enemies[2].following = true
		
		# Locks
		scene_switcher.set_locked(true)
		player.set_locked(true)
		
		# Mine area
		get_tree().call_group("mine", "collect_max")
		
		# Rock
		remove_child(rock)
		rock.show()
		rock.set_past(true)
		scene_switcher.get_present().add_child(rock)
		rock.set_original_pos(enemies[0].position + Vector2.LEFT * 32)
		
		# Gold
		player.set_gold(5)
		
		enemies[0].read([
			"We'll see 'bout that. Meet us at the railroad tracks with yer gadget.",
			"No funny business, otherwise yer pardner gets it."
		])
		yield(enemies[0], "dialog_finished")
		var size := get_viewport_rect().size
		enemies[0].goto_pos(player.position + size)
		yield(enemies[0], "reached_waypoint")
		player.countdown_started = true
		prevent_skip_collision.call_deferred("set_disabled", true)
		for enemy in enemies:
			enemy.hide()
		friend.hide()
		player.set_locked(false)
		scene_switcher.set_locked(false)
		banner.display("Save Your Friend")
		get_tree().call_group("mine", "set_max_gold", 15)
		return
	elif Variables.intro_cutscene:
		scene_switcher.toggle_scene_no_anim()
		var past: Node = scene_switcher.get_past()
		var present: Node = scene_switcher.get_present()
		
		# Mine found
		mine_found_collision.call_deferred("set_disabled", true)
		
		# Scientist
		remove_child(scientist)
		present.add_child(scientist)
		
		# Player
		player.position.x = Variables.player_x_pos
		
		# Friend
		friend.hide()
		
		# Enemies
		for enemy in enemies:
			enemy.show()
			enemy.set_facing(-1)
		enemies[0].position.x = player.position.x + 64
		enemies[1].kidnap = true
		enemies[1].position.x = player.position.x + 128
		enemies[2].position.x = player.position.x + 160
		enemies[1].follow_target = enemies[0]
		enemies[1].follow_dist = 32
		enemies[2].follow_target = enemies[1]
		
		# Gun
		prop_gun.position = enemies[0].position
		prop_gun.show()
		
		# Bullet
		var prop_bullet := PropBullet.instance()
		prop_bullet.position = bullet_pos.global_position
		prop_bullet.stop_point = player.position.x + 16
		past.add_child(prop_bullet)
		
		# Locks
		scene_switcher.set_locked(true)
		player.set_locked(true)
		
		# Mine area
		get_tree().call_group("mine", "collect_max")
		
		# Gold
		player.set_gold(5)
		
		gun_cutscene(prop_bullet, past)
		return
	player.set_facing(-1)
	player.read([
		"I wish I wasn't so [shake]poor[/shake][color=#00FFFFFF]...\n\n[color=yellow]Press {interact} to continue",
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
		"How would you like to tes-- use my new [color=white][rainbow]time warp device[/rainbow][/color]?"
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
	player.hud.show()


func _on_Player_collected_gold(amt: int) -> void:
	if amt != 5 or Variables.intro_cutscene:
		return
	player.set_locked(true)
	player.set_facing(1)
	Variables.player_x_pos = player.position.x
	get_tree().call_group("global_camera", "set_focus", player)
	player.read([
		"Wow! This is so easy. It's like taking candy from a baby",
	])
	yield(player, "dialog_finished")
	get_tree().call_group("global_camera", "set_focus", enemies[0])
	var start: float = player.position.x + get_viewport_rect().size.x + 16
	for i in len(enemies):
		enemies[i].show()
		enemies[i].position.x = start + 32 * i
		enemies[i].set_facing(-1)
	enemies[1].following = true
	enemies[1].follow_target = enemies[0]
	enemies[1].follow_dist = 32
	enemies[2].following = true
	enemies[2].follow_target = enemies[1]
	enemies[0].read([
		"What in tarnation are y'all doin' on our land?",
		"Y'all are rustlin' our gold!"
	])
	yield(enemies[0], "dialog_finished")
	get_tree().call_group("global_camera", "set_focus", player,
			Vector2.RIGHT * 32)
	enemies[0].goto_pos(
		Vector2(player.position.x + 64, 0)
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
	friend.following = false
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
	enemies[1].kidnap = true
	friend.hide()
	enemies[1].goto_pos(pos)
	yield(enemies[1], "reached_waypoint")
	enemies[1].set_facing(-1)
	prop_gun.position = enemies[0].position
	enemies[0].read([
		"And, as a little parting gift, here's some lead"
	])
	yield(enemies[0], "dialog_finished")
	prop_gun.show()
	yield(get_tree().create_timer(0.5, false), "timeout")
	var past: Node = scene_switcher.get_past()
	var prop_bullet := PropBullet.instance()
	prop_bullet.position = bullet_pos.global_position
	prop_bullet.stop_point = player.position.x + 16
	past.add_child(prop_bullet)
	prop_gun.play("shoot")
	gun_cutscene(prop_bullet, past)


func gun_cutscene(prop_bullet: Node, past: Node) -> void:
	shot_sfx.play()
	get_tree().call_group("global_camera", "set_zoom", Vector2.ONE / 2)
	get_tree().call_group("global_camera", "set_focus", prop_bullet,
			Vector2.DOWN * 15)
	yield(get_tree().create_timer(1.0, false), "timeout")
	scene_switcher.set_locked(false)
	dialog_player.read([
		"[color=yellow]Press {warp} to time warp"
	], false)
	enemies[1].following = true
	enemies[2].following = true
	remove_child(friend)
	past.add_child(friend)
	for enemy in enemies:
		remove_child(enemy)
		past.add_child(enemy)
	remove_child(prop_gun)
	past.add_child(prop_gun)
	scientist.hide()
	var present: Node = scene_switcher.get_present()
	remove_child(rock)
	present.add_child(rock)
	yield(scene_switcher, "switched_scene")
	rock.show()
	rock.set_original_pos(enemies[0].position + Vector2.LEFT * 32)
	
	dialog_player.stop()
	scene_switcher.set_locked(true)
	yield(get_tree().create_timer(0.5, false), "timeout")
	get_tree().call_group("global_camera", "set_zoom", Vector2.ONE)
	get_tree().call_group("global_camera", "set_focus", player,
			Vector2.LEFT * 16)
	player.read([
		"Whew! That was a close one..."
	])
	yield(player, "dialog_finished")
	scientist.position.x = player.position.x - 32
	scientist.set_facing(1)
	scientist.show()
	appear.emitting = true
	scientist.read([
		"STOP!"
	])
	yield(scientist, "dialog_finished")
	player.set_facing(-1)
	scientist.read([
		"I haven't told you the one caveat to the device. It only lasts for a short duration",
		"Let's see how much time you have left",
	])
	yield(scientist, "dialog_finished")
	scientist.goto_pos(player.position + Vector2.LEFT * 8)
	yield(scientist, "reached_waypoint")
	yield(get_tree().create_timer(0.5, false), "timeout")
	scientist.read([
		"Oh no! You spent so long in the past!",
		"There's only a minute remaining on the device!",
	])
	yield(scientist, "dialog_finished")
	scientist.goto_pos(player.position + Vector2.LEFT * 32)
	player.read([
		"One minute?! My friend is still in the past"
	])
	yield(scientist, "reached_waypoint")
	scientist.set_facing(1)
	if player.dialog_player.has_dialog:
		yield(player, "dialog_finished")
	scientist.read([
		"Ooh... that is quite the predicament",
		"Umm... uhh... Good luck!"
	])
	yield(scientist, "dialog_finished")
	player.read([
		"Wait! You gotta help me"
	])
	yield(get_tree().create_timer(0.5, false), "timeout")
	scientist.anim_sprite.hide()
	appear.emitting = true
	if player.dialog_player.has_dialog:
		yield(player, "dialog_finished")
	player.read([
		"Dammit!"
	])
	yield(player, "dialog_finished")
	Variables.intro_cutscene = true
	player.set_locked(false)
	scene_switcher.set_locked(false)
	get_tree().call_group("global_camera", "set_focus", player)
	yield(scene_switcher, "switched_scene")
	shot_sfx.play(0.1)
	scene_switcher.set_locked(true)
	player.set_locked(true)
	if player.position.x - player.collision.shape.extents.x <= \
			prop_bullet.position.x:
		var bullet_line := BulletLine.instance()
		bullet_line.from_point = prop_bullet.position
		bullet_line.to_point = Vector2(player.position.x,
				prop_bullet.position.y)
		bullet_line.dur = abs(player.position.x - prop_bullet.position.x) / \
				prop_bullet.actual_speed
		prop_bullet.queue_free()
		add_child(bullet_line)
		player.kill()
		return
	player.set_facing(1)
	yield(get_tree().create_timer(0.5, false), "timeout")
	prop_gun.hide()
	enemies[0].read([
		"Am I havin' a vision or did that bullet pass through him?"
	])
	yield(enemies[0], "dialog_finished")
	player.read([
		"Give my friend back! I'll give you the gold"
	])
	yield(player, "dialog_finished")
	enemies[0].read([
		"Hold yer horses now. Y'all seem to have a contraption that gives y'all superpowers",
		"I want that"
	])
	yield(enemies[0], "dialog_finished")
	player.read([
		"No way! It's not yours to take"
	])
	yield(player, "dialog_finished")
	enemies[0].read([
		"We'll see 'bout that. Meet us at the railroad tracks with yer gadget.",
		"No funny business, otherwise yer pardner gets it."
	])
	yield(enemies[0], "dialog_finished")
	var size := get_viewport_rect().size
	enemies[0].goto_pos(player.position + size)
	yield(enemies[0], "reached_waypoint")
	player.countdown_started = true
	prevent_skip_collision.call_deferred("set_disabled", true)
	for enemy in enemies:
		enemy.hide()
	friend.hide()
	player.set_locked(false)
	scene_switcher.set_locked(false)
	banner.display("Save Your Friend")
	get_tree().call_group("mine", "set_max_gold", 15)
	Variables.first_puzzle = true


func _on_won(pos: Vector2) -> void:
	scene_switcher.get_past().remove_child(friend)
	add_child(friend)
	friend.position = pos
	friend.show()
	friend.set_facing(player.position.x - friend.position.x)
	friend.read([
		"Thanks for saving me!",
		"[shake]I was so scared"
	])
	yield(friend, "dialog_finished")
	player.read([
		"It was no problem",
		"What was a problem was the fact that [shake]I DIDN'T GET RICH"
	])
	yield(player, "dialog_finished")
	SceneHandler.goto_scene(menu_scene)
