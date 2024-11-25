extends Control

signal start

@onready var started: bool = false

func _input(event: InputEvent) -> void:
	if started: return
	if event is InputEventKey or event is InputEventJoypadButton:
		start.emit()
		started = true


func dismiss() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color("FFFFFF", 0), 0.8)
	tween.play()
	await tween.finished
	queue_free()
