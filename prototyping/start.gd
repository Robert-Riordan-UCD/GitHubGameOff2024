extends Sprite2D

func _on_area_2d_body_exited(body: Node2D) -> void:
	SpeedrunTimer.reset_timer()
	print("STARTING TIMER")
