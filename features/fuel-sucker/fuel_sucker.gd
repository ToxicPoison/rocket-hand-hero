extends Node2D

@onready var area := $Area2D
@onready var lines := [$Line2D]

var player : Object = null
var resting := false
var transition_amt := 0.0
var transition_spd := 5.0
var target_pos := Vector2.ZERO
var last_pos := Vector2.ZERO

func _ready():
	#setup lines
	var new_line = $Line2D.duplicate()
	add_child(new_line)
	lines.append(new_line)
	lines[1].position = $FuelSucker2.position
	
	var outlines = []
	for line in lines: #add outlines
		var outline = line.duplicate()
		outline.position = line.position
		outline.width += 4
		outline.default_color = Color.BLACK
		outline.z_index = -1
		add_child(outline)
		outlines.append(outline)
	
	for outline in outlines:
		lines.append(outline)
	
	#connections
	area.body_entered.connect(on_body_entered)
	area.body_exited.connect(on_body_exited)
	
func on_body_entered(body):
	if body is Player and body.get_rocket():
		player = body
		body.get_rocket().fuel = 0.0
		resting = false
		
func on_body_exited(body):
	if body == player:
		last_pos = player.global_position
		player = null
		
func _process(delta):
	if player:
		if transition_amt < 1.0:
			transition_amt += delta * transition_spd
			if transition_amt > 1.0: transition_amt = 1.0
	elif not resting:
		if transition_amt > 0.0:
			transition_amt -= delta * transition_spd
			if transition_amt < 0.0:
				transition_amt = 0.0
				resting = true
		
	if player or not resting:
		for line in lines:
			if player:
				target_pos = player.global_position - line.global_position
				line.points[1] = lerp(Vector2.ZERO, target_pos, transition_amt)
			else:
				target_pos = last_pos - line.global_position
				line.points[1] = lerp(Vector2.ZERO, target_pos, max(transition_amt, 0.0))
			
	
