extends Node2D

const moving_lightning = preload("res://scenes/Moving Lightning.tscn")

func _ready():
	$AnimatedSprite.set_flip_h(randi() % 2)

func _physics_process(delta):
	if $RayCast2D.is_colliding() and not ($CooldownTimer.time_left or $ChargeTimer.time_left):
		if $RayCast2D.get_collider().get_class() == "KinematicBody2D":
			$ChargeTimer.start()
			$AnimatedSprite.set_animation("charging")

func _on_ChargeTimer_timeout():
	$AnimatedSprite.set_animation("idle")
	var beam = moving_lightning.instance()
	add_child(beam)
	$Shoot.play()
	$CooldownTimer.start()

func reset():
	$ChargeTimer.stop()
	$CooldownTimer.start()
	$AnimatedSprite.set_animation("idle")
