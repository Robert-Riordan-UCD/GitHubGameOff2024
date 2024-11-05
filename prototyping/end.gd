extends Sprite2D

@onready var player: PlatformerController2D = $"../Player"

var high_score_sent: bool = false

func _on_area_2d_body_entered(_body: Node2D) -> void:
	if high_score_sent: return
	var time_to_win = SpeedrunTimer.get_run_time()
	high_score_sent = true
	SilentWolf.Scores.save_score("dev", time_to_win)
	print("Score sent: " + str(time_to_win))
