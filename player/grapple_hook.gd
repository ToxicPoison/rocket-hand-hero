extends RigidBody2D

var grapple : Object
const LIFETIME := 3.0

func _ready():
	await get_tree().create_timer(LIFETIME).timeout
	if not grapple.grapple_hooked:
		grapple.delete_hook()
