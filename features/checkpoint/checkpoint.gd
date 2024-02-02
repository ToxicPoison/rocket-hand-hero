extends Node2D

@onready var area = $Area2D
@export var refueling : bool = true

func _ready():
	area.body_entered.connect(on_body_entered)


func on_body_entered(body):
	if body is Player:
		body.last_checkpoint = self
