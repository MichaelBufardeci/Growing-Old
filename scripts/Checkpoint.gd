extends Area2D

var active := false

func _ready():
	$AnimatedSprite.set_animation("sapling")
	$AnimatedSprite.set_frame(randi() % 4)
	$AnimatedSprite.set_flip_h(randi() % 2)

func _on_Checkpoint_body_entered(body):
	if body.alive:
		get_tree().call_group("oranges", "remove")
		get_tree().call_group_flags(2, "score", "checkpoint")
		if not active:
			get_tree().call_group_flags(2, "checkpoints", "reset")
			body.set("checkpoint", self.position)
			active = true
			$AnimatedSprite.set_animation("tree")
			$Chime.play()

func reset():
	if active:
		active = false
		$AnimatedSprite.set_animation("sapling")
