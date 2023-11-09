extends Node2D

@export var off_color = Color.AQUA
@onready var timer := $Timer
var can_fuel := true

func _ready():
	timer.timeout.connect(on_timeout)

func refuel_player(player):
	if can_fuel:
		player.get_rocket().refuel()
		timer.start()
		can_fuel = false
		modulate = off_color
	
func on_timeout():
	can_fuel = true
	modulate = Color.WHITE
