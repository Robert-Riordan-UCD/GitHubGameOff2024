extends Sprite2D

@onready var player: PlatformerController2D = $"../Player"
@onready var leaderboard: CanvasLayer = $"../Leaderboard"
@onready var run_time: Label = $"../GUI/MarginContainer/RunTime"

var high_score_sent: bool = false

func _on_area_2d_body_entered(_body: Node2D) -> void:
	if high_score_sent: return
	
	# Sending negative number so the smallest number will be at the top of the leader board
	var time_to_win = -snapped(SpeedrunTimer.get_run_time(), 0.001)
	run_time.active = false
	high_score_sent = true
	var sw_result: Dictionary = await SilentWolf.Scores.save_score("dev", time_to_win).sw_save_score_complete
	print("Score persisted successfully: " + str(sw_result.score_id))
	print("Score sent: " + str(time_to_win))
	leaderboard.display()
