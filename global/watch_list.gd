extends CanvasLayer

var tracked_vars := {
	"Example": 99
}

func _unhandled_input(event):
	if event.is_action_pressed("debug"):
		visible = !visible

func watch(var_name, var_value):
	tracked_vars[var_name] = var_value

func _process(delta):
	var output_string := ""
	for var_name in tracked_vars:
		output_string += "%s: %s\n" % [var_name, tracked_vars[var_name]]
	$Label.text = output_string
