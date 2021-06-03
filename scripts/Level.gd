extends Node

const normal_volume = -10
const quiet_volume = -30

var victory := false

func _ready():
	randomize()
	$Music.play()

func _process(delta):
	#reset to last checkpoint
	if Input.is_action_just_released("ui_reset"):
		$Player.respawn()
		get_tree().call_group("oranges", "reset")
		get_tree().call_group("score", "reset")
		get_tree().call_group("coils", "reset")
		get_tree().call_group("bolts", "queue_free")
		$Music.volume_db = normal_volume
	#debug stuff
	if OS.is_debug_build():
		if Input.is_key_pressed(KEY_F1):
			$Player.call("grow_to_child")
		if Input.is_key_pressed(KEY_F2):
			$Player.call("grow_to_adult")
		if Input.is_key_pressed(KEY_F3):
			$Player.call("grow_to_elderly")
		if Input.is_key_pressed(KEY_F4):
			get_tree().reload_current_scene()
	#change to victory music
	if victory:
		if $Music.volume_db > -80:
			$Music.volume_db = lerp($Music.volume_db, -80, 0.1)
		else:
			$Music.stop()
		if $Victory.volume_db < normal_volume:
			$Victory.volume_db = lerp($Victory.volume_db, normal_volume, 0.1)
		

func quiet():
	$Music.volume_db = quiet_volume

func victory():
	victory = true
	$Victory.play()

func _on_EasterEgg_body_exited(body):
	if $HUD/HBoxContainer/Score.count == 18:
		body.call("easter_egg")
