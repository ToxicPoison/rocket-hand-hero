extends Node2D

@export var draw_outlines : bool = true
@export var draw_inner_shade : bool = true
@export var make_collisions : bool = true

@export var line_weight := 3.0
@export var shade_dist : float = 16.0
@export var shade_color : Color = Color(0.0, 0.02, 0.05)

func _ready():
	for child in get_children():
		if child is Polygon2D:
			
			#draw outlines
			if draw_outlines:
				var lines := Line2D.new()
				lines.closed = true
				lines.position = child.position
				lines.scale = child.scale
				lines.points = child.polygon
				lines.default_color = Color.BLACK
				lines.width = line_weight * 2.0
				if $Outlines: $Outlines.add_child(lines)
			
			#draw inner shading
			if draw_inner_shade:
				var shade := Polygon2D.new()
				shade.polygon = child.polygon
				shade.position = child.position
				shade.scale = child.scale
				shade.color = shade_color
				var poly_size : int = shade.polygon.size()
				for i in poly_size:
					var vlast : Vector2 = child.polygon[(i - 1) % poly_size]
					var vnext : Vector2 = child.polygon[(i + 1) % poly_size]
					var vert : Vector2 = child.polygon[i]
					var midpt := (vlast + vnext) * 0.5
					var dir := (vert - midpt).normalized()
					if Geometry2D.is_point_in_polygon(vert + dir * shade_dist, child.polygon):
						shade.polygon[i] = vert + dir * shade_dist
					else:
						shade.polygon[i] = vert - dir * shade_dist
				if $Shade: $Shade.add_child(shade)
			
			#make collisions
			if make_collisions:
				var stat := StaticBody2D.new()
				var col := CollisionPolygon2D.new()
				stat.add_child(col)
				child.add_child(stat)
				stat.position = Vector2.ZERO
				stat.rotation = 0.0
				stat.scale = Vector2.ONE
				col.polygon = child.polygon
	
	move_child($Shade, get_child_count())
