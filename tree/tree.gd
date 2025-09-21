class_name TreeNature
extends StaticBody2D

signal cutted(tree_position: Vector2)

@export var max_health: int = 4
var health := max_health

func _on_hurt_box_area_entered(_area: Area2D) -> void:
	health -= 1
	if health == 0:
		cutted.emit(global_position)
		queue_free()
