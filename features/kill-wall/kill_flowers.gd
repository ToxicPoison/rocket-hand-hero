extends Node2D

@onready var sprite = $KillFlowers
@onready var area = $Area2D
@onready var anger_area = $AngerArea

func _ready():
	area.body_entered.connect(on_body_entered)
	anger_area.body_entered.connect(on_approached)
	anger_area.body_exited.connect(on_left)


func on_body_entered(body):
	if body is Player:
		body.respawn()

func on_approached(body):
	if body is Player:
		sprite.frame = 3
		
func on_left(body):
	if body is Player:
		sprite.frame = 0
