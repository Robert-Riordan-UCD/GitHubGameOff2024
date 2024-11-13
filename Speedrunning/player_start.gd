extends Node2D

signal player_not_started
signal player_started

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		player_not_started.emit()


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		player_started.emit()
