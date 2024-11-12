extends Node2D

signal player_reached_finish


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		player_reached_finish.emit()
