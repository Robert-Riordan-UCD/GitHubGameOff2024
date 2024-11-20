extends Node2D

signal player_reached_finish

@onready var finished: bool = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if finished: return
	if body is Player and not body.dead:
		player_reached_finish.emit()
		finished = true
