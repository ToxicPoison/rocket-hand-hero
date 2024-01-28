extends Node2D

func get_normal() -> Vector2:
	return $RayCast2D.get_collision_normal()
