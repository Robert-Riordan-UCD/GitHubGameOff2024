extends Control

signal restart

@onready var loading: Label = $HBoxContainer/VBoxContainer/Loading
@onready var leaderboard_table: GridContainer = $HBoxContainer/VBoxContainer/LeaderboardTable
const LEADER_BOARD_LABEL = preload("res://Speedrunning/leader_board_label.tscn")

var players_score: float

func display_leaderboard(new_time: float) -> void:
	clear_leader_board()
	visible = true
	players_score = new_time
	var score_id: String = await submit_score(new_time)
	await display_top_ten(score_id)
	insert_buffer()
	leaderboard_table.visible = true
	await display_player_score(score_id)
	loading.visible = false


func hide_leader_board() -> void:
	loading.visible = true
	leaderboard_table.visible = false
	visible = false


func clear_leader_board() -> void:
	for child in leaderboard_table.get_children().slice(3):
		leaderboard_table.remove_child(child)
		child.queue_free()


# TODO: Handle error result
func submit_score(new_time: float) -> String:
	var sw_result: Dictionary = await SilentWolf.Scores.save_score("new dev", -new_time).sw_save_score_complete
	return sw_result.score_id


# TODO: Handle error result
func display_top_ten(new_score_id) -> void:
	var sw_result: Dictionary = await SilentWolf.Scores.get_scores().sw_get_scores_complete
	var scores = sw_result.scores
	var rank: int = 1
	for score in scores:
		append_score(rank, score.player_name, -score.score, score.score_id == new_score_id)
		rank += 1


func display_player_score(score_id: String) -> void:
	var sw_result = await SilentWolf.Scores.get_scores_around(score_id, 1).sw_get_scores_around_complete
	# Score above
	var above = sw_result.scores_above[0]
	append_score(above.position, above.player_name, -above.score)

	# Players score
	append_score(above.position+1, "--FIXME--", players_score, true)

	# Score below
	if sw_result.scores_below.size() == 0: return # Player is last :o
	var below = sw_result.scores_below[0]
	append_score(below.position, below.player_name, -below.score)
	

func append_score(rank: int, player_name: String, score: float, is_new_score: bool=false) -> void:
	var rank_label: Label = LEADER_BOARD_LABEL.instantiate()
	rank_label.text = str(rank)
	leaderboard_table.add_child(rank_label)
	
	var name_label: Label = LEADER_BOARD_LABEL.instantiate()
	name_label.text = player_name
	leaderboard_table.add_child(name_label)
	
	var score_label: Label = LEADER_BOARD_LABEL.instantiate()
	score_label.text = "%.3fs" % score
	leaderboard_table.add_child(score_label)
	
	rank_label.flash = is_new_score
	name_label.flash = is_new_score
	score_label.flash = is_new_score


func insert_buffer() -> void:
	var rank_label: Label = LEADER_BOARD_LABEL.instantiate()
	leaderboard_table.add_child(rank_label)
	
	var name_label: Label = LEADER_BOARD_LABEL.instantiate()
	name_label.text = '...'
	leaderboard_table.add_child(name_label)
	
	var score_label: Label = LEADER_BOARD_LABEL.instantiate()
	leaderboard_table.add_child(score_label)


func _on_button_pressed() -> void:
	hide_leader_board()
	restart.emit()
