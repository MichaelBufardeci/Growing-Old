extends Area2D

var speed := 200

func _physics_process(delta):
	position -= Vector2(0, delta * speed)

func _on_Moving_Lightning_body_entered(body):
	queue_free()

func destroy():
	print("destroying")
	queue_free()
