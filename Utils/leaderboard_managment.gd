extends Control

var leaderboards: Array[String] = ["main", "0", "1", "2", "3"]


func save_leaderboards() -> void:
	for leaderboard in leaderboards:
		var sw_result: Dictionary = await SilentWolf.Scores.get_scores(0, leaderboard).sw_get_scores_complete
		var time_stamp: String = Time.get_datetime_string_from_datetime_dict(Time.get_datetime_dict_from_system(), false)
		var file = FileAccess.open("res://Speedrunning/LeaderboardBackups/"+leaderboard+"/leaderboard"+time_stamp+".json", FileAccess.WRITE)
		file.store_string(str(sw_result))
	print("Leaderboards Saved")


func _on_download_pressed() -> void:
	save_leaderboards()


func _on_clear_pressed() -> void:
	await save_leaderboards()
	for leaderboard in leaderboards:
		SilentWolf.Scores.wipe_leaderboard(leaderboard)
	print("Leaderboards Cleared")


@onready var file_dialog: FileDialog = $VBoxContainer/HBoxContainer/FileDialog
func _on_upload_leaderboard_pressed() -> void:
	file_dialog.popup_centered(Vector2(640, 320))


func _on_file_dialog_file_selected(path: String) -> void:
	upload_leaderboard(path)


func upload_leaderboard(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		print("File not found: " + path)
		return
	
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	if not (error == OK):
		print("Could not parse file")
		return
	
	var scores: Array = json.data["scores"]
	var leaderboard: String = json.data["ld_name"]
	
	var uploaded: int = 0
	for score in scores:
		var sw_result: Dictionary = await SilentWolf.Scores.save_score(
			score["player_name"],
			score["score"],
			leaderboard
		).sw_save_score_complete
		if sw_result["error"]:
			print("Failed to upload score: " + str(score))
		else:
			uploaded += 1
	
	print("Uploaded ", uploaded, "/", scores.size())
