extends Node2D

#The speech bubble is THIS much bigger than the bounds of the text:
const BG_MARGIN : float = 10.0
var text_speed : float = 60.0 # in letters/sec

@onready var text = $Text
@onready var bubble = $Background

@export_multiline var message : String = "a"

var growing := false
var growth : float = 0.0

func generate_bubble() -> void:
	text.position = -text.size / 2
	bubble.scale = (text.size + BG_MARGIN * Vector2.ONE) / bubble.texture.get_size()

func initiate() -> void:
	text.text = message
	growth = 0.0
	text.visible_characters = 0
	text.size = Vector2.ZERO
	growing = true
	generate_bubble()

func _ready() -> void:
	initiate()

func _process(delta) -> void:
	if growing == false: return
	if text.visible_characters > text.text.length():
		growing = false
		return
	growth += delta * text_speed
	text.visible_characters = floori(growth)
	generate_bubble()
	
