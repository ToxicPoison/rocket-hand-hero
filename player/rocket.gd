extends Node2D

@onready var player = get_parent()

const DEF_FORCE := 500.0
const MAX_FORCE := 1500.0
var acceleration := 200.0
@onready var force : float = DEF_FORCE
var firing_time := 0.0
var jump_time_delay := 0.5
var can_fire := true
var smoothing = 0.05

var fuel : float
const MAX_FUEL := 5.0

@onready var exhaust := $CPUParticles2D
@export var gradient = Gradient.new()


func _ready():
	gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_LINEAR
	fuel = MAX_FUEL

func _process(delta):
	rotation = player.mpos.angle()
	exhaust.color = gradient.sample(fuel / MAX_FUEL)
	
func _physics_process(delta):
	if can_fire and !player.is_on_floor() and Input.is_action_pressed("fire") and !player.grappling and fuel - delta > 0:
		if force < MAX_FORCE:
			force += delta * acceleration
			if force > MAX_FORCE: force = MAX_FORCE
		player.flying = true
		player.velocity = player.velocity.lerp(player.mpos.normalized() * force, smoothing)
		fuel -= delta
		exhaust.emitting = true
	else:
		force = DEF_FORCE
		player.flying = false
		exhaust.emitting = false
		
func jump_timer_start():
	can_fire = false
	await get_tree().create_timer(jump_time_delay).timeout
	can_fire = true

func refuel():
	fuel = MAX_FUEL
