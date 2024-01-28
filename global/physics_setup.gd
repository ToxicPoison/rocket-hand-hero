extends Node

# Changes physics settings depending on the monitor's framerate to ensure properly smooth experience
func _ready():
	Engine.set_physics_ticks_per_second(DisplayServer.screen_get_refresh_rate())
	# Remember, things will move slowly if
	# the FPS goes below (1/max_physics_steps_per_frame) * physics_ticks_per_second.
	# So if this becomes an issue, adjust max_physics_steps_per_frame accrodingly depending
	# on screen refresh rate.
