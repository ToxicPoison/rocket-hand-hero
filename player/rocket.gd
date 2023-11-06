extends Node2D

@onready var player = get_parent()

const DEF_FORCE := 500.0
const MAX_FORCE := 1500.0
var acceleration := 100.0
@onready var force : float = DEF_FORCE
var firing_time := 0.0
var jump_time_delay := 0.5
var can_fire := true
var smoothing = 0.05

func _physics_process(delta):
	if can_fire and !player.is_on_floor() and Input.is_action_pressed("fire"):
		if force < MAX_FORCE:
			force += delta * acceleration
			if force > MAX_FORCE: force = MAX_FORCE
		player.flying = true
		player.velocity = player.velocity.lerp(player.mpos.normalized() * force, smoothing)
	else:
		force = DEF_FORCE
		player.flying = false
		
func jump_timer_start():
	can_fire = false
	await get_tree().create_timer(jump_time_delay).timeout
	can_fire = true
