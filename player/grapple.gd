extends Node2D

const HOOK_PATH := preload("res://player/grapple_hook.tscn")
@onready var player := get_parent()
@onready var line := $Line2D

var grapple_speed := 800.0
var jump_time_delay := 0.2
var can_grapple := true
var grapple_out := false
var grapple_hooked := false

var hook : Object = null

func _process(delta):
	if Input.is_action_just_pressed("grapple") and can_grapple and !player.is_on_floor():
		delete_hook()
		shoot_grapple()
	if !Input.is_action_pressed("grapple") and grapple_hooked and hook:
		delete_hook()
		
func _physics_process(delta):
	if grapple_out:
		line.visible = true
		line.points[1] = hook.position - player.position
	else:
		line.visible = false

func jump_timer_start():
	can_grapple = false
	await get_tree().create_timer(jump_time_delay).timeout
	can_grapple = true

func shoot_grapple():
	hook = HOOK_PATH.instantiate()
	player.get_parent().add_child(hook)
	hook.grapple = self
	hook.set_deferred("position", player.position)
	hook.set_deferred("linear_velocity", player.mpos.normalized() * grapple_speed + player.velocity)
	hook.body_entered.connect(on_hook_contact)
	grapple_out = true

func on_hook_contact(body):
	hook.set_deferred("freeze", true)
	grapple_hooked = true
	
func delete_hook():
	if hook:
		hook.queue_free()
		hook = null
	grapple_out = false
	grapple_hooked = false
