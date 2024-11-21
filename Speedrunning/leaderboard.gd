extends Control

signal restart
signal preload_complete

@onready var loading: Label = $HBoxContainer/VBoxContainer/Loading
@onready var leaderboard_table: GridContainer = $HBoxContainer/VBoxContainer/LeaderboardTable
@onready var button: Button = $HBoxContainer/VBoxContainer/Button
const LEADER_BOARD_LABEL = preload("res://Speedrunning/leader_board_label.tscn")

var players_score: float
var top_ten: Array

@onready var preloading: bool = false
@onready var preloaded: bool = false


func preload_leaderboard() -> void:
	preloading = true
	clear_leader_board()
	await fetech_top_ten()
	preloaded = true
	preload_complete.emit()
	preloading = false


func display_leaderboard(new_time: float, player_name: String) -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	button.grab_focus()
	visible = true
	players_score = new_time
	var score_id: String = await submit_score(new_time, player_name)
	if preloaded:
		pass
	elif preloading and not preloaded:
		await preload_complete
	elif not preloading:
		await preload_leaderboard()
	var player_in_top_ten: bool = update_top_ten(new_time, player_name)
	display_top_ten()
	leaderboard_table.visible = true
	if not player_in_top_ten:
		insert_buffer()
		await display_player_score(score_id, player_name)
	loading.visible = false
	preloading = false
	preloaded = false


func hide_leader_board() -> void:
	loading.visible = true
	leaderboard_table.visible = false
	visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func clear_leader_board() -> void:
	for child in leaderboard_table.get_children().slice(3):
		leaderboard_table.remove_child(child)
		child.queue_free()


# TODO: Handle error result
func submit_score(new_time: float, player_name: String) -> String:
	var sw_result: Dictionary = await SilentWolf.Scores.save_score(player_name, -new_time).sw_save_score_complete
	return sw_result.score_id


func fetech_top_ten() -> void:
	var sw_result: Dictionary = await SilentWolf.Scores.get_scores().sw_get_scores_complete
	var scores = sw_result.scores
	top_ten.clear()
	for score in scores:
		top_ten.append(Score.new(score.player_name, -score.score))


# Return true if the player is in the top ten
func update_top_ten(score, player_name) -> bool:
	var player_position: int = 0
	for player in top_ten:
		if score < player.score: break
		player_position += 1
	if player_position >= 9: return false
	top_ten.insert(player_position, Score.new(player_name, score, true))
	return true


# TODO: Handle error result
func display_top_ten() -> void:
	var rank: int = 1
	for score: Score in top_ten:
		append_score(rank, score.player_name, score.score, score.is_user)
		rank += 1


func display_player_score(score_id: String, player_name: String) -> void:
	var sw_result = await SilentWolf.Scores.get_scores_around(score_id, 1).sw_get_scores_around_complete
	# Score above
	if sw_result.scores_above.size() == 0: return # Player is first :D
	var above = sw_result.scores_above[0]
	append_score(above.position, above.player_name, -above.score)

	# Players score
	append_score(above.position+1, player_name, players_score, true)

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
