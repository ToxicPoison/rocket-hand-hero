extends Area2D

@export_node_path("CharacterBody2D") var player_path
@onready var player

func _ready():
	if player_path: player = get_node(player_path)
	self.connect("body_entered", on_body_entered)
	
func on_body_entered(body):
	if player && body==player:
		player.respawn()
