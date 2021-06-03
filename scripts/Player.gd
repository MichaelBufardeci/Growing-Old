extends KinematicBody2D

enum AGES {CHILD, ADULT, ELDERLY}

const acceleration = 0.1
const drag = 0.25
const max_run = 200
const jump_speed = 300
const max_fall = 450
const gravity = 30
const air_mult = 0.75
const start = Vector2(44, 580)

var move := Vector2.ZERO
var coyote := false
var age := 0
var checkpoint := Vector2()
var alive := true
var shocked := false
var animate := false
var finished := false
var zoom := 0.25
var easter_egg := false

func _physics_process(delta):
	move = move_and_slide(move, Vector2.UP)
	if alive:
	### movement
		## horizontal
		#get movement direction
		var input_dir := 0.0
		if Input.is_action_pressed("ui_left"):
			input_dir -= 1
		if Input.is_action_pressed("ui_right"):
			input_dir += 1
		#check that we're moving in one direction
		if input_dir != 0:
			#if we're in the air, decrease movement power
			var mult := air_mult
			if is_on_floor():
				mult = 1
			#move in the direction input
			move.x = lerp(move.x, input_dir * max_run * mult, acceleration)
			#move the camera so we can better see where we're headed
			$Camera2D.position.x = lerp($Camera2D.position.x, input_dir * 32, acceleration)
		else:
			#otherwise slow down
			move.x = lerp(move.x, 0, drag)
		## vertical
		#if we're slower than terminal velocity, gravity pulls us downwards
		if move.y < max_fall:
			move.y += gravity
		#otherwise, slow us until we reach terminal velocity
		else:
			move.y = lerp(move.y, max_fall, drag)
		if not is_on_floor() and move.y >= 0:
			#if we just started falling, start coyote timer
			if coyote:
				$CoyoteTime.start()
			#move camera to better see where we're headed
			$Camera2D.position.y = lerp($Camera2D.position.y, 0, acceleration)
		else:
			$Camera2D.position.y = lerp($Camera2D.position.y, -16, acceleration)
		#set flag so we can check next frame
		coyote = is_on_floor()
		#check if we're jumping
		if Input.is_action_just_pressed("ui_up"):
			#if we're on the floor, jump
			if is_on_floor():
				move.y = -jump_speed
				$Jump.play()
			#if we just started falling, jump anyway
			elif not $CoyoteTime.is_stopped():
				$CoyoteTime.stop()
				move.y = -jump_speed
				$Jump.play()
			#update animation
			if move.y < 0:
				draw_jump()
		### animation
		#character faces the input movement and runs
		if input_dir != 0:
			$AnimatedSprite.flip_h = move.x < 0
			if is_on_floor():
				draw_run()
		#stretch and squish for jumps
		if is_on_floor():
			$AnimatedSprite.scale = Vector2.ONE
		else:
			$AnimatedSprite.scale = Vector2(0.9, 1.1)
		#ensure we're animating
		if not animate:
			draw_idle()
		#reset for next frame
		animate = false
		#zoom
		$Camera2D.zoom = Vector2(lerp($Camera2D.zoom.x, zoom, acceleration), lerp($Camera2D.zoom.y, zoom, acceleration))
	elif shocked:
		#twitch
		move.x += rand_range(-1, 1)
		if is_on_floor():
			move.y += rand_range(-150, 0)
		$AnimatedSprite.scale = Vector2(rand_range(0.75, 1.25), rand_range(0.75, 1.25))
		$AnimatedSprite.get_material().set_shader_param("flash_state", randf())
		if randf() > 0.9:
			$AnimatedSprite.set_flip_h(not $AnimatedSprite.is_flipped_h())
		if not easter_egg:
			var rand := randi() % 3
			if rand == 0:
				draw_idle()
			elif rand == 1:
				draw_run()
			elif rand == 2:
				draw_jump()
		#fall
		rotation_degrees = lerp(rotation_degrees, 90 + rand_range(-15, 15), rand_range(-0.1, 0.5))
		if move.y < max_fall:
			move.y += gravity / 2.0
		else:
			move.y = lerp(move.y, max_fall, drag)
	else:
		#slow down our horizontal movement
		move.x = lerp(move.x, 0, acceleration)
		#if we're slower than terminal velocity, gravity pulls us downwards
		if move.y < max_fall:
			move.y += gravity
		#otherwise, slow us until we reach terminal velocity
		else:
			move.y = lerp(move.y, max_fall, drag)
	if finished:
		$Camera2D.limit_top = -96
		$Camera2D.position.y = lerp($Camera2D.position.y, -48, acceleration)

func grow_to_child():
	if age != AGES.CHILD:
		age = AGES.CHILD
		$AnimatedSprite.animation = "child idle"
		$ChildHitbox.set_deferred("disabled", false)
		$AdultHitbox.set_deferred("disabled", true)
		$ElderlyHitbox.set_deferred("disabled", true)
		zoom = 0.25
		
func grow_to_adult():
	if age != AGES.ADULT:
		age = AGES.ADULT
		$AnimatedSprite.animation = "adult idle"
		$ChildHitbox.set_deferred("disabled", true)
		$AdultHitbox.set_deferred("disabled", false)
		$ElderlyHitbox.set_deferred("disabled", true)
		zoom = 0.5
		
func grow_to_elderly():
	if age != AGES.ELDERLY:
		age = AGES.ELDERLY
		$AnimatedSprite.animation = "elderly idle"
		$ChildHitbox.set_deferred("disabled", true)
		$AdultHitbox.set_deferred("disabled", true)
		$ElderlyHitbox.set_deferred("disabled", false)
		zoom = 1.0

func respawn():
	move = Vector2.ZERO
	var respawn_point := checkpoint
	if age == AGES.CHILD:
		respawn_point.y += 8
	elif age == AGES.ADULT:
		respawn_point.y += 1
	elif age == AGES.ELDERLY:
		respawn_point.y -= 13
	position = respawn_point
	rotation_degrees = 0
	$AnimatedSprite.get_material().set_shader_param("flash_state", 0)
	shocked = false
	alive = true
	easter_egg = false
	draw_idle()
	$Timer.start()

func shock():
	if not shocked and not $Timer.time_left:
		get_tree().call_group("level", "quiet")
		$Shock.play()
		shocked = true
		alive = false
		move = Vector2.ZERO

func draw_idle():
	animate = true
	if age == AGES.CHILD:
		$AnimatedSprite.set_animation("child idle")
	elif age == AGES.ADULT:
		$AnimatedSprite.set_animation("adult idle")
	elif age == AGES.ELDERLY:
		$AnimatedSprite.set_animation("elderly idle")

func draw_run():
	animate = true
	if age == AGES.CHILD:
		$AnimatedSprite.set_animation("child run")
	elif age == AGES.ADULT:
		$AnimatedSprite.set_animation("adult run")
	elif age == AGES.ELDERLY:
		$AnimatedSprite.set_animation("elderly run")

func draw_jump():
	animate = true
	if age == AGES.CHILD:
		$AnimatedSprite.set_animation("child jump")
	elif age == AGES.ADULT:
		$AnimatedSprite.set_animation("adult jump")
	elif age == AGES.ELDERLY:
		$AnimatedSprite.set_animation("elderly jump")

func easter_egg():
	easter_egg = true
	$AnimatedSprite.set_animation("easter egg")
