extends Path2D

@export var loop : bool = false
@export var fall_off_start : bool = true
@export var fall_off_end : bool = true
@export_node_path("CharacterBody2D") var player_path

@onready var player : Player = null
@onready var player_rotator : Object = null

var mountable := true
var true_velocity := Vector2.ZERO # Velocity of the player going along the rail
var grind_speed = 0.0
var player_original_parent : Object = null
const MOUNT_DIST := 16.0
const GRAVITY_FACTOR := 10.0

func _ready() -> void:
	for point in curve.get_baked_points():
		$Line2D.add_point(point)
	
	if player_path:
		player = get_node(player_path)
		player_rotator = player.get_rotator()

func _physics_process(delta):
	if player and !player.grappling and !player.current_rail:
		var local_player_pos = player.global_position - global_position
		var closest_point = curve.get_closest_point(local_player_pos)
		var p_in_range : bool = closest_point.distance_to(local_player_pos) < MOUNT_DIST
		var p_moving_down : bool = player.velocity.dot(Vector2.DOWN) > 0
		
		if mountable and p_in_range and p_moving_down:
			mount(closest_point)
		if not mountable and not p_in_range:
			reenable()
	
	# Move player along rail
	if player and player.current_rail == self:
		player.global_position = $PathFollow2D.global_position
		player_rotator.rotation = $PathFollow2D.rotation
		
		$Ride.pitch_scale = absf(grind_speed) / 1000.0
		$Ride.volume_db = minf(absf(grind_speed) / 500.0 - 3.0, 4.0)
		if Input.is_action_pressed("jump") or ( ((player.get_rocket() and player.get_rocket().fuel <= 0) or !player.get_rocket()) and player.wanna_jump ): # 
			dismount(true)
		
		var next_pos : float = $PathFollow2D.progress + grind_speed * delta
		if not loop:
			var ahead : bool = next_pos > curve.get_baked_length()
			var behind : bool = next_pos < 0
			if ahead and fall_off_end:
				dismount(false)
			elif behind and fall_off_start:
				dismount(false)
			elif (ahead or behind) and (!fall_off_end or !fall_off_start):
				grind_speed = -0.4 * grind_speed #change this number if you  want
				$Dismount.play()
		
		true_velocity = (curve.sample_baked(next_pos) - curve.sample_baked($PathFollow2D.progress)) / delta
		
		if grind_speed > 0: grind_speed += true_velocity.normalized().dot(Vector2.DOWN) * GRAVITY_FACTOR
		else: grind_speed -= true_velocity.normalized().dot(Vector2.DOWN) * GRAVITY_FACTOR
		
		if loop or (next_pos < curve.get_baked_length() and next_pos > 0): $PathFollow2D.progress = next_pos
		
func mount(point) -> void:
	mountable = false
	$Line2D.modulate = Color.RED
	$Mount.play()
	$Ride.playing = true
	
	# Set player's on-rail speed to how fast the player is moving (along the rail's tangent)

	var mount_offset := curve.get_closest_offset(point)
	var tangent_dir = get_tangent(point, false)
	grind_speed = player.velocity.dot(tangent_dir)
	
	# Place player along rail
	$PathFollow2D.progress = mount_offset
	player.current_rail = self
	player.velocity = Vector2.ZERO
	player.get_node("CollisionShape2D").set_deferred("disabled", true)
	
func dismount(jump):
	#$Dismount.pitch_scale = true_velocity.length() / 1000.0
	$Dismount.play()
	$Ride.playing = false
	player.current_rail = null
	player_rotator.rotation = 0
	player.velocity = true_velocity
	player.get_node("CollisionShape2D").set_deferred("disabled", false)
	if jump: 
		player.velocity += $PathFollow2D.get_global_transform().y * -player.JUMP_VELOCITY

func reenable():
	mountable = true
	$Line2D.modulate = Color.WHITE

func get_tangent(pt, point_is_global) -> Vector2:
	if point_is_global: pt = pt - position
	var mount_offset := curve.get_closest_offset(pt)
	var pt2 := curve.sample_baked(mount_offset + 8, true)
	#$To.position = pt
	#$Fro.position = pt2
	return (pt2 - pt).normalized()
