extends Control

var leaderboards: Array[String] = ["main", "0", "1", "2", "3"]


func save_leaderboards() -> void:
	for leaderboard in leaderboards:
		var sw_result: Dictionary = await SilentWolf.Scores.get_scores(0, leaderboard).sw_get_scores_complete
		var time_stamp: String = Time.get_datetime_string_from_datetime_dict(Time.get_datetime_dict_from_system(), false)
		var file = FileAccess.open("res://Speedrunning/LeaderboardBackups/"+leaderboard+"/leaderboard"+time_stamp+".json", FileAccess.WRITE)
		file.store_string(str(sw_result))


func _on_download_pressed() -> void:
	save_leaderboards()


func _on_clear_pressed() -> void:
	await save_leaderboards()
	for leaderboard in leaderboards:
		SilentWolf.Scores.wipe_leaderboard(leaderboard)
