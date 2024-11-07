extends Sprite2D

@onready var run_time: Label = $"../GUI/MarginContainer/RunTime"


func _on_area_2d_body_exited(body: Node2D) -> void:
	SpeedrunTimer.reset_timer()
	run_time.active = true
