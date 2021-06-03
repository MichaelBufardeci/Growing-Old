extends Area2D

var age := 0
var step := 0
var player
var action := false

func _process(delta):
	if action:
		if age  == 1:
			if step == 1:
				$AnimatedSprite.set_animation("medium")
				$AnimatedSprite.offset.y = 32
				$Chime.play()
				$Timer.start()
				action = false
			elif step == 2:
				player.call("grow_to_adult")
				$Chime.play()
				$Timer.start()
				action = false
			elif step == 3:
				player.set_position(player.start)
				step = 0
				$CollisionShape2D.set_deferred("disabled", false)
				player.alive = true
		elif age == 2:
			if step == 1:
				$AnimatedSprite.set_animation("large")
				$AnimatedSprite.offset.y = 0
				$Chime.play()
				$Timer.start()
				action = false
			elif step == 2:
				player.call("grow_to_elderly")
				$Chime.play()
				$Timer.start()
				action = false
			elif step == 3:
				player.set_position(player.start)
				step = 0
				$CollisionShape2D.set_deferred("disabled", false)
				player.alive = true
		elif age == 3:
			if step == 1:
				$AnimatedSprite.set_animation("huge")
				$AnimatedSprite.offset.y = -64
				$Chime.play()
				$Timer.start()
				action = false
			if step == 2:
				player.finished = true
				get_tree().call_group("level", "victory")
				step = 0

func _on_Timer_timeout():
	step += 1
	action = true

func _on_Finish_body_entered(body):
	if action:
		action = false
	else:
		$CollisionShape2D.set_deferred("disabled", true)
		player = body
		body.alive = false
		age += 1
		$Timer.start()
