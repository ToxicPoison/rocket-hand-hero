extends Camera2D

@onready var player = get_parent()

var ooffset = Vector2.ZERO

var target_position := Vector2.ZERO
var current_unrounded_position := Vector2.ZERO
var smooth = 0.05; #num from [0,1] (1 = no smoothing)

func _ready():
	recenter_camera()
	
func recenter_camera():
	current_unrounded_position = player.global_position + ooffset

func _process(delta):
	target_position = player.global_position + ooffset
	current_unrounded_position = current_unrounded_position.lerp(target_position, smooth)
	position = current_unrounded_position.round()
