class_name Player extends CharacterBody2D

@onready var cursor = $Cursor
@onready var camera = $Camera2D

var mpos := Vector2.ZERO

var flying := false
var grappling := false
var jumped := false
var current_rail : Object = null


var wanna_jump := false

const SPEED := 350.0
var target_speed := 0.0
const JUMP_VELOCITY := 500.0
var accel := 0.2

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var last_checkpoint : Object = null

func _unhandled_input(event):
	if event.is_action_pressed("respawn"): respawn()

func _process(delta):
	mpos = get_viewport().get_mouse_position() + (camera.get_screen_center_position() - position) - get_viewport_rect().size * 0.5
	mpos *= Vector2.ONE / camera.zoom
	cursor.position = mpos
	
	# Jump by swiping up
	const min_swipe_speed = 1000
	wanna_jump = Input.is_action_pressed("walk") and Input.get_last_mouse_velocity().y < -min_swipe_speed
	WatchList.watch("mouse vel", Input.get_last_mouse_velocity().y)
	WatchList.watch("wanna_jump", wanna_jump)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor() and !flying and !current_rail:
		velocity.y += gravity * delta
	
	if (wanna_jump or Input.is_action_pressed("jump")) and is_on_floor() and !grappling:
		velocity.y = -JUMP_VELOCITY
		$AudioStreamPlayer2D.play()
		if $Rocket:
			$Rocket.jump_timer_start()
		if $Grapple:
			$Grapple.jump_timer_start()
	
	target_speed = 0.0
		
	if is_on_floor() and Input.is_action_pressed("walk") and !flying and !grappling and !current_rail:
		target_speed = mpos.normalized().x * SPEED
		if !$StepSound.playing:
			$StepSound.play()
	elif Input.is_action_pressed("walk") and !flying and !current_rail:
		velocity.x += mpos.normalized().x * SPEED * delta * 0.1
		
	if is_on_floor():
		velocity.x = lerpf(velocity.x, target_speed, accel)
		
	move_and_slide()
	
	camera.ooffset = velocity * 0.1 + mpos * 0.05

func get_rocket():
	return $Rocket

func get_grapple():
	return $Grapple

func respawn():
	$DeathSound.play()
	
	if current_rail:
		current_rail.dismount(false)
	
	velocity = Vector2.ZERO
	if last_checkpoint:
		position = last_checkpoint.position
	else:
		position = Vector2.ZERO
	if $Grapple: $Grapple.unhook()
	if $Rocket:
		if (last_checkpoint and last_checkpoint.refueling) or !last_checkpoint: $Rocket.refuel()
		else: $Rocket.fuel = 0.0
	
	
