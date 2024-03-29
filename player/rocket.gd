extends Node2D

@onready var player = get_parent()

const DEF_FORCE := 400.0
const MAX_FORCE := 800.0
var acceleration := 200.0
@onready var force : float = DEF_FORCE
var firing_time := 0.0
var jump_time_delay := 0.5
var can_fire := true
var smoothing = 0.05

var fuel := 0.0
const MAX_FUEL := 5.0

@onready var exhaust := $CPUParticles2D
@onready var rocket_origin = $"../Rotators/RocketOrigin"
@onready var fuel_pack := $"../Rotators/FuelPack"
@onready var grapple = $"../Grapple"
@export var gradient = Gradient.new()


func _ready():
	gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_LINEAR

func _process(delta):
	global_position = rocket_origin.global_position
	rotation = player.mpos.angle()
	var fuel_ratio = fuel / MAX_FUEL
	exhaust.color = gradient.sample(fuel_ratio)
	fuel_pack.set_as_ratio(fuel_ratio)
	$Sprite2D.visible = (!can_fire or player.flying or !player.is_on_floor()) and (grapple.state == grapple.State.UNGRAPPLED)
	
func _physics_process(delta):
	if can_fire and !player.is_on_floor() and Input.is_action_pressed("fire") and !player.grappling and fuel - delta > 0:
		if force < MAX_FORCE:
			force += delta * acceleration
			if force > MAX_FORCE: force = MAX_FORCE
		player.flying = true
		if !player.current_rail:
			player.velocity = player.velocity.lerp(player.mpos.normalized() * force, smoothing)
		else:
			player.current_rail.grind_speed += (player.mpos.normalized() * force).dot(player.current_rail.get_tangent(player.global_position, true)) * delta
		fuel -= delta
		exhaust.emitting = true
		if !$RocketSound.playing:
			$RocketSound.play()
	else:
		force = DEF_FORCE
		player.flying = false
		exhaust.emitting = false
		$RocketSound.stop()
		
func jump_timer_start():
	can_fire = false
	await get_tree().create_timer(jump_time_delay).timeout
	can_fire = true

func refuel():
	fuel = MAX_FUEL
	$RefuelSound.play()
