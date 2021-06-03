extends Area2D

func _ready():
	$AnimatedSprite.set_frame(randi() % 3)
	$AnimatedSprite.set_flip_h(randi() % 2)
	$AnimatedSprite.set_flip_v(randi() % 2)


func _on_Lightning_body_entered(body):
	body.call("shock")
