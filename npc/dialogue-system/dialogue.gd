class_name Dialogue extends Node2D

#The speech bubble is THIS much bigger than the bounds of the text:
const BG_MARGIN : float = 40.0
var text_speed : float = 60.0 # in letters/sec

@onready var text = $Text
@onready var bubble = $Background

@export_multiline var message : String = "a"

## If set to true, this speech bubble follows the player after spawning to keep the text on-screen.
@export var follow_player : bool = false
## Leave empty if Follow Player is set to false.
@export_node_path("Player") var player_path
var player : Object = null

var growing := false
var growth : float = 0.0

var fading := false
var fade : float = 1.0
var fade_speed : float = 2.0

var initial_offset_from_player := Vector2.ZERO

func generate_bubble() -> void:
	text.position = -text.size / 2
	bubble.scale = (text.size + BG_MARGIN * Vector2.ONE) / bubble.texture.get_size()

func initiate() -> void:
	visible = true
	modulate = Color(Color.WHITE, 1.0)
	fade = 1.0
	if follow_player and player: initial_offset_from_player = global_position - player.global_position
	text.text = message
	growth = 0.0
	text.visible_characters = 0
	text.size = Vector2.ZERO
	growing = true
	generate_bubble()

func disappear() -> void:
	if fade > 0.99: fading = true

func _ready() -> void:
	visible = false
	if player_path: player = get_node(player_path)

func _process(delta) -> void:
	if fading and fade > 0.0:
		fade -= delta * fade_speed
		modulate = Color(Color.WHITE, fade)
	if not (fade > 0.0):
		fading = false
		visible = false
	if not growing: return
	if text.visible_characters > text.text.length():
		growing = false
		return
	growth += delta * text_speed
	text.visible_characters = floori(growth)
	generate_bubble()
	
func _physics_process(delta: float) -> void:
	if not visible: return
	if not follow_player: return
	if not player: return
	global_position = player.global_position + initial_offset_from_player
