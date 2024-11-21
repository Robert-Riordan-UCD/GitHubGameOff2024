extends Control


func save_leaderboard() -> void:
	var sw_result: Dictionary = await SilentWolf.Scores.get_scores(0).sw_get_scores_complete
	var time_stamp: String = Time.get_datetime_string_from_datetime_dict(Time.get_datetime_dict_from_system(), false)
	var file = FileAccess.open("res://Speedrunning/LeaderboardBackups/leaderboard"+time_stamp+".json", FileAccess.WRITE)
	file.store_string(str(sw_result))


func _on_download_pressed() -> void:
	save_leaderboard()


func _on_clear_pressed() -> void:
	save_leaderboard()
	SilentWolf.Scores.wipe_leaderboard()
