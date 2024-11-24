extends Node2D

signal collected

@onready var area_2d: Area2D = $Area2D


func _on_area_2d_body_entered(_body: Node2D) -> void:
	collected.emit()
	visible = false
	area_2d.set_deferred("monitoring", false)


func reset() -> void:
	visible = true
	area_2d.set_deferred("monitoring", true)
