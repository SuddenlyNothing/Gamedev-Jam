extends Node2D

signal won(pos)

onready var enemy := $EnemyPuppet
onready var gun_detector := $GunDetector
onready var past_notify := $PastNotify
onready var enemy2 := $EnemyPuppet2
onready var enemy3 := $EnemyPuppet3
onready var boss := $Boss

onready var enemies := [
	$EnemyPuppet4, $EnemyPuppet5, $EnemyPuppet6
]
onready var past_notifies := [
	$PastNotify2, $PastNotify3, $PastNotify4
]


func _ready() -> void:
	enemy2.follow_target = enemy
	enemy3.follow_target = enemy2
	enemy2.following = true
	enemy3.following = true
	enemies[1].follow_target = enemies[0]
	enemies[2].follow_target = enemies[1]
	enemies[2].following = true
	enemies[1].following = true


func _on_PastNotify_body_entered(body: Node) -> void:
	gun_detector.disable()
	past_notify.disable()
	get_tree().call_group("global_camera", "set_focus", enemy, (body.position - enemy.position) / 2)
	body.set_locked(true)
	body.countdown_started = false
	get_tree().call_group("scene_switcher", "set_locked", true)
	if body.gun:
		enemy.read([
			"I reckon y'all have a quarrel with our deal"
		])
		yield(enemy, "dialog_finished")
		body.read([
			"What makes you think that?"
		])
		yield(body, "dialog_finished")
		enemy.read([
			"That newfangled shooter danglin' 'round yer waist is a telltale sign",
			"Well, I reckon I was never one for peaceful resolutions anyhow"
		])
		yield(enemy, "dialog_finished")
	else:
		enemy.read([
			"Whoa there, hold it!",
			"I reckon y'all have come to hand over yer contraption"
		])
		yield(enemy, "dialog_finished")
		body.read([
			"What makes you think that?"
		])
		yield(body, "dialog_finished")
		enemy.read([
			"Y'all waltz in here without so much as a peashooter, and expect to get something out of it?",
			"I reckon if y'all ain't givin' up that gizmo, I'll have to beat it out of ya."
		])
		yield(enemy, "dialog_finished")
	enemy.shoot(body.position + Vector2.UP * 8)
	body.kill()


func _on_GunDetector_hit() -> void:
	past_notify.disable()
	gun_detector.disable()
	
	var player: Node = get_tree().get_nodes_in_group("player")[0]
	get_tree().call_group("global_camera", "set_focus", enemy)
	player.set_locked(true)
	player.countdown_started = false
	get_tree().call_group("scene_switcher", "set_locked", true)
	
	enemy.read([
		"Enemy attack!",
		"Hunker down, boys!"
	])
	yield(enemy, "dialog_finished")
	get_tree().call_group("global_camera", "set_focus", player)
	yield(get_tree().create_timer(0.5, false), "timeout")
	enemy.goto_pos(enemy.position + get_viewport_rect().size)
	player.set_loop_shoot(true)
	yield(get_tree().create_timer(3, false), "timeout")
	player.has_ammo = false
	yield(get_tree().create_timer(1, false), "timeout")
	player.set_loop_shoot(false)
	enemy.hide()
	enemy2.hide()
	enemy3.hide()
	
	player.read([
		"That should be enough"
	])
	yield(player, "dialog_finished")
	
	player.set_locked(false)
	player.countdown_started = true
	get_tree().call_group("scene_switcher", "set_locked", false)


func _on_PastNotify2_body_entered(body: Node) -> void:
	past_notifies[0].disable()
	get_tree().call_group("global_camera", "set_focus", enemies[0],
			(body.position - enemies[0].position) / 2)
	body.set_locked(true)
	body.countdown_started = false
	get_tree().call_group("scene_switcher", "set_locked", true)
	body.set_facing(1)
	if body.shield:
		enemies[0].read([
			"Hurry up! He's run dry",
			"Turn him into a pile o' rubble"
		])
		yield(enemies[0], "dialog_finished")
		body.actual_shield.show()
		for i in 6:
			for enemy in enemies:
				enemy.shoot(body.position + Vector2(13, -8 + (randf() - 0.5) * 4))
				yield(get_tree().create_timer(0.2, false), "timeout")
		body.actual_shield.hide()
		enemies[0].read([
			"He can't be killed! Git outta here!"
		])
		yield(enemies[0], "dialog_finished")
		get_tree().call_group("global_camera", "set_focus", body)
		enemies[0].goto_pos(enemies[0].position + get_viewport_rect().size)
		yield(enemies[0], "reached_waypoint")
		for i in enemies:
			i.hide()
		
		body.set_locked(false)
		body.countdown_started = true
		get_tree().call_group("scene_switcher", "set_locked", false)
	else:
		enemies[0].read([
			"He ain't nothin' without his bullets"
		])
		yield(enemies[0], "dialog_finished")
		enemies[0].shoot(body.position + Vector2.UP * 8)
		body.kill()


func _on_PastNotify3_body_entered(body: Node) -> void:
	past_notifies[1].disable()
	get_tree().call_group("global_camera", "set_focus", boss,
			(body.position - boss.position) / 2)
	body.set_locked(true)
	body.countdown_started = false
	get_tree().call_group("scene_switcher", "set_locked", true)
	boss.read([
		"Y'all done torn my boys apart",
		"The least y'all can do is provide me some compensation",
		"[shake]I'm gonna wrench that contraption outta yer hands if it's the last thing I do!"
	])
	yield(boss, "dialog_finished")
	get_tree().call_group("global_camera", "set_focus", body)
	body.set_locked(false)
	body.countdown_started = true
	get_tree().call_group("scene_switcher", "set_locked", false)
	boss.start(body)


func _on_PastNotify4_body_entered(body: Node) -> void:
	past_notifies[2].disable()
	if body.scissor:
		emit_signal("won", Vector2(1678, 60))
		body.set_locked(true)
		get_tree().call_group("scene_switcher", "set_locked", true)
		get_tree().call_group("scene_switcher", "toggle_scene")
	else:
		body.set_locked(true)
		get_tree().call_group("scene_switcher", "set_locked", true)
		boss.read([
			"Y'all ain't got no shears"
		])
		yield(boss, "dialog_finished")
		body.set_locked(false)
		get_tree().call_group("scene_switcher", "set_locked", false)
