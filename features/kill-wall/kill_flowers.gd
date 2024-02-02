extends Node2D

@onready var sprite = $KillFlowers
@onready var area = $Area2D
@onready var anger_area = $AngerArea
var target = null

func _ready():
	area.body_entered.connect(on_body_entered)
	anger_area.body_entered.connect(on_approached)
	#anger_area.body_exited.connect(on_left)

func _process(delta):
	if target == null:
		return
	var dist_to_target = global_position.distance_to(target.global_position)
	var max_frame = (sprite.hframes * sprite.vframes) - 1
	var new_frame = (1.0 - dist_to_target / 150.0 + 0.6) * max_frame
	new_frame = clamp(new_frame, 0.0, max_frame)
	sprite.frame = new_frame
	

func on_body_entered(body):
	if body is Player:
		body.respawn()

func on_approached(body):
	if body is Player:
		target = body
		
#func on_left(body):
	#if body is Player:
		#sprite.frame = 0
