extends Area2D

@export_enum("Appear", "Disappear", "Appear then disappear") var function = 0
## Time dialogue will be visible in seconds (if set to 'appear then disappear')
@export var time_visible := 1.0
@export var trigger_once := true
## If this thing can trigger more than once, how much time before it can be triggered again?
@export_node_path("Dialogue") var target_dialogue
var target_node : Dialogue = null
var triggered : bool = false

func _ready() -> void:
	#assert(target_dialogue, "you're supposed to give this node some dialogue to activate IDIOT!!")
	if target_dialogue: target_node = get_node(target_dialogue)
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body) -> void:
	if not body is Player: return
	if target_node.visible: return
	match function:
		0:
			target_node.initiate()
		1:
			target_node.disappear()
		2:
			target_node.initiate()
			await get_tree().create_timer(time_visible).timeout
			target_node.disappear()
	if trigger_once: queue_free()
