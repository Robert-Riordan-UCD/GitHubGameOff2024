extends Sprite2D

var started: bool = false

func _on_area_2d_body_entered(_body: Node2D) -> void:
	if started: return
	started = true
	SpeedrunTimer.reset_timer()
	print("STARTING TIMER")
