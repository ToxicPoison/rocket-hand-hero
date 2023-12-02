extends CanvasGroup

func _ready():
	for child in get_children():
		if child is Polygon2D:
			var stat := StaticBody2D.new()
			var col := CollisionPolygon2D.new()
			stat.add_child(col)
			child.add_child(stat)
			stat.position = Vector2.ZERO
			stat.rotation = 0.0
			stat.scale = Vector2.ONE
			col.polygon = child.polygon
