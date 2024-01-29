extends Node2D

const HOOK_PATH := preload("res://player/grapple_hook.tscn")
@onready var player := get_parent()
@onready var line := $Line2D
@onready var cursor = $"../Cursor/Area2D"
@onready var grapple_origin = $"../Rotators/GrappleOrigin"

enum State { UNGRAPPLED, GRAPPLING, GRAPPLED }
var state = State.UNGRAPPLED

var grapple_speed := 800.0
var grapple_force := 6.0
var friction := 0.99
var jump_time_delay := 0.2
var can_grapple := true
var grappling_progress := 0.0
const RANGE := 64.0 * 8.0
const GRAPPLING_TIME = 0.06 # In seconds

var target : Object = null

func _process(delta):
	if Input.is_action_just_pressed("grapple"):
		if target == null:
			for area in cursor.get_overlapping_areas():
				if area.is_in_group("grappleable") and area.get_parent().global_position.distance_to(player.global_position) < RANGE:
					begin_grapple(area)
					break
	if target and Input.is_action_just_released("grapple"):
		unhook()
	
	if grappling_progress < GRAPPLING_TIME:
		grappling_progress += delta
	else:
		grappling_progress = GRAPPLING_TIME
		if state == State.GRAPPLING:
			state = State.GRAPPLED
			grappled(target)
	WatchList.watch("grapple state", state)
	WatchList.watch("grappling_progress", grappling_progress)
	
func _physics_process(delta):
	line.points[0] = grapple_origin.global_position - player.global_position
	if target:
		line.visible = true
		if state == State.GRAPPLING:
			var target_loc = target.global_position - player.global_position
			var grapple_progress_proportion = clamp(grappling_progress / GRAPPLING_TIME, 0, 1)
			line.points[1] = lerp(Vector2.ZERO, target_loc, grapple_progress_proportion)
		elif state == State.GRAPPLED:
			player.velocity += (target.global_position - player.global_position) * grapple_force * delta
			player.velocity *= friction
			line.points[1] = target.global_position - player.global_position
		
	else:
		line.visible = false

func begin_grapple(obj):
	target = obj
	player.grappling = true
	state = State.GRAPPLING
	grappling_progress = 0.0
	$GrapplingSound.play()

func grappled(obj):
	if player.current_rail: player.current_rail.dismount(true)
	$GrappledSound.play()
	$GrapplingSound.stop()
	if target.get_parent() is FuelNode:
		target.get_parent().refuel_player(player)
	

func unhook():
	target = null
	player.grappling = false
	state = State.UNGRAPPLED

func jump_timer_start():
	can_grapple = false
	await get_tree().create_timer(jump_time_delay).timeout
	can_grapple = true
