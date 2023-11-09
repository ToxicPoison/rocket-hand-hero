extends Node2D

const HOOK_PATH := preload("res://player/grapple_hook.tscn")
@onready var player := get_parent()
@onready var line := $Line2D
@onready var cursor = $"../Cursor/Area2D"

var grapple_speed := 800.0
var grapple_force := 6.0
var friction := 0.99
var jump_time_delay := 0.2
var can_grapple := true
const RANGE := 64.0 * 8.0

var target : Object = null

func _process(delta):
	if Input.is_action_just_pressed("grapple"):
		if target == null:
			for area in cursor.get_overlapping_areas():
				if area.is_in_group("grappleable") and area.get_parent().position.distance_to(player.position) < RANGE:
					grapple(area.get_parent())
					break
	if target and Input.is_action_just_released("grapple"):
		unhook()
		
func _physics_process(delta):
	if target:
		player.velocity += (target.position - player.position) * grapple_force * delta
		player.velocity *= friction
		line.visible = true
		line.points[1] = target.position - player.position
	else:
		line.visible = false

func grapple(obj):
	target = obj
	target.refuel_player(player)
	player.grappling = true
	
func unhook():
	target = null
	player.grappling = false

func jump_timer_start():
	can_grapple = false
	await get_tree().create_timer(jump_time_delay).timeout
	can_grapple = true
