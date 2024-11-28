extends TextureRect

@export var speedrun_timer: SpeedrunTimer


func _ready() -> void:
	visible = get_tree().paused


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().paused = not get_tree().paused
		if get_tree().paused:
			visible = true
			speedrun_timer.stop_timer()
		else:
			speedrun_timer.resume_timer()
			visible = false
