extends Path2D

@export_node_path("CharacterBody2D") var player_path
@onready var player : Player = null

var mountable := true
var true_velocity := Vector2.ZERO # Velocity of the player going along the rail
var grind_speed = 0.0
var player_original_parent : Object = null
const MOUNT_DIST := 16.0
const GRAVITY_FACTOR := 10.0

func _ready() -> void:
	for point in curve.get_baked_points():
		$Line2D.add_point(point)
	
	if player_path: player = get_node(player_path)

func _physics_process(delta):
	WatchList.watch("rail grinding speed", grind_speed)
	WatchList.watch("downness", true_velocity.normalized().dot(Vector2.DOWN))
	WatchList.watch("player rail rotation up", -$PathFollow2D.get_global_transform().y)
	if player:
		var local_player_pos = player.global_position - global_position
		var closest_point = curve.get_closest_point(local_player_pos)
		var p_in_range : bool = closest_point.distance_to(local_player_pos) < MOUNT_DIST
		var p_moving_down : bool = player.velocity.dot(Vector2.DOWN) > 0
		
		if mountable and p_in_range and p_moving_down and !player.current_rail:
			mount(closest_point)
		if not mountable and not p_in_range:
			reenable()
	
	# Move player along rail
	if player.current_rail == self:
		if player.wanna_jump or Input.is_action_pressed("jump"):
			dismount(true)
		
		var next_pos : float = $PathFollow2D.progress + grind_speed * delta
		if next_pos > curve.get_baked_length() - 2 or next_pos < 0:
			dismount(false)
		else:
			true_velocity = (curve.sample_baked(next_pos) - curve.sample_baked($PathFollow2D.progress)) / delta
			if grind_speed > 0: grind_speed += true_velocity.normalized().dot(Vector2.DOWN) * GRAVITY_FACTOR
			else: grind_speed -= true_velocity.normalized().dot(Vector2.DOWN) * GRAVITY_FACTOR
			$PathFollow2D.progress = next_pos
		
func mount(point) -> void:
	# Set player's on-rail speed to how fast the player is moving (along the rail's tangent)
	mountable = false
	$Line2D.modulate = Color.RED
	var mount_offset := curve.get_closest_offset(point)
	var tangent_dir = get_tangent(point)
	grind_speed = player.velocity.dot(tangent_dir)
	
	# Place player along rail
	$PathFollow2D.progress = mount_offset
	player_original_parent = player.get_parent()
	player.current_rail = self
	player.reparent($PathFollow2D)
	player.velocity = Vector2.ZERO
	player.position = Vector2.ZERO
	player.rotation = 0
	
func dismount(jump):
	player.current_rail = null
	player.reparent(player_original_parent)
	player.rotation = 0
	player.velocity = true_velocity
	if jump: 
		player.velocity += $PathFollow2D.get_global_transform().y * -player.JUMP_VELOCITY

func reenable():
	mountable = true
	$Line2D.modulate = Color.WHITE

func get_tangent(pt) -> Vector2:
	var mount_offset := curve.get_closest_offset(pt)
	var pt2 := curve.sample_baked(mount_offset + 0.5, true)
	return (pt2 - pt).normalized()
