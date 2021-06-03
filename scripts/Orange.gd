extends Node

var collected := false
var sum_time := 0.0
var offset := 0.0

func _ready():
	offset = randf()
	$Sprite.set_frame(randi() % 4)

func _process(delta):
	sum_time += delta
	$Sprite.position.x = sin((sum_time + offset) * 3) 
	$Sprite.position.y = cos((sum_time + offset) * 3)

func _on_Orange_body_entered(body):
	if body.alive:
		$Chime.play()
		$CollisionShape2D.set_deferred("disabled", true)
		get_tree().call_group("score", "collect")
		collected = true
		$Sprite.visible = false
	
func reset():
	if collected:
		$CollisionShape2D.set_deferred("disabled", false)
		collected = false
		$Sprite.visible = true
		
func remove():
	if collected:
		queue_free()
