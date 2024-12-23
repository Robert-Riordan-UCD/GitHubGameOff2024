extends Control

signal restart
signal preload_complete

@onready var loading: Label = $HBoxContainer/VBoxContainer/Loading
@onready var leaderboard_table: GridContainer = $HBoxContainer/VBoxContainer/LeaderboardTable
@onready var button: Button = $HBoxContainer/VBoxContainer/Button
@onready var trophies_collected: Label = $HBoxContainer/VBoxContainer/Trophy/TrophiesCollected
const LEADER_BOARD_LABEL = preload("res://Speedrunning/leader_board_label.tscn")

var players_score: float
var top_ten: Array
var current_leaderboard: int

@onready var preloading: bool = false
@onready var preloaded: bool = false


func preload_leaderboard(trophy_count: int) -> void:
	current_leaderboard = trophy_count
	preloading = true
	clear_leader_board()
	preloaded = await fetech_top_ten()
	preload_complete.emit()
	preloading = false


func display_leaderboard(new_time: float, player_name: String, trophy_count: int) -> void:
	players_score = new_time
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	visible = true
	
	trophies_collected.text = str(trophy_count)
	if current_leaderboard != trophy_count: # Any preloaded leaderboard is for the wrong trophy count
		current_leaderboard = trophy_count
		preloaded = false
		preloading = false
	
	if preloaded:
		pass
	elif preloading and not preloaded:
		await preload_complete
	elif not preloading:
		await preload_leaderboard(current_leaderboard)

	if not preloaded:
		loading.text = "Error: Failed to load leaderboard"
		return
	
	var submitted: bool = await submit_score(new_time, player_name)
	if not submitted:
		loading.text = "Error: Failed to submit score"
		return
	
	var player_in_top_ten: bool = update_top_ten(new_time, player_name)
	display_top_ten()
	leaderboard_table.visible = true
	
	if not player_in_top_ten:
		await display_player_score(player_name)
	
	loading.visible = false
	preloading = false
	preloaded = false
	
	button.grab_focus()


func hide_leader_board() -> void:
	loading.visible = true
	loading.text = "Loading..."
	leaderboard_table.visible = false
	visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func clear_leader_board() -> void:
	for child: LeaderboardLabel in leaderboard_table.get_children().slice(3):
		leaderboard_table.remove_child(child)
		child.queue_free()


# Returns true if the score was successfully submitted
func submit_score(new_time: float, player_name: String) -> bool:
	var score: Dictionary = await SilentWolf.Scores.save_score(PlayerID.get_id(), -new_time, str(current_leaderboard), {"player_name": player_name}).sw_save_score_complete
	if score.error != null:
		push_warning("Failed to submit score")
		push_warning(score.error)
		return false
	return true


# Return true if the top 10 were successfully fetched
func fetech_top_ten() -> bool:
	top_ten.clear()
	
	var sw_result: Dictionary = await SilentWolf.Scores.get_scores(10, str(current_leaderboard)).sw_get_scores_complete
	if sw_result.error:
		push_warning("Failed load top 10")
		push_warning(sw_result.error)
		return false
	
	var scores: Array = sw_result.scores
	for score: Dictionary in scores:
		top_ten.append(Score.new(score.metadata.player_name, -score.score))
	return true

# Return true if the player is in the top ten
func update_top_ten(score: float, player_name: String) -> bool:
	var player_position: int = 0
	for player: Score in top_ten:
		if score < player.score:
			top_ten.insert(player_position, Score.new(player_name, score, true))
			return true
		player_position += 1
	if top_ten.size() < 10:
		top_ten.insert(top_ten.size(), Score.new(player_name, score, true))
		return true
	return false


func display_top_ten() -> void:
	var rank: int = 1
	for score: Score in top_ten:
		append_score(rank, score.player_name, score.score, score.is_user)
		rank += 1


# Return true if the nearby scores were successfully fetched
func display_player_score(player_name: String) -> bool:
	var sw_result: Dictionary = await SilentWolf.Scores.get_scores_around(-players_score, 1, str(current_leaderboard)).sw_get_scores_around_complete
	if sw_result.error:
		push_warning("Failed to fetch neighbouring scores")
		push_warning(sw_result)
		return false
	
	insert_buffer()

	# Score above
	if sw_result.scores_above.size() == 0: return true # Player is first :D
	var above: Dictionary = sw_result.scores_above[0]
	append_score(above.position, above.metadata.player_name, -above.score)

	# Players score
	append_score(above.position+1, player_name, players_score, true)

	# Score below
	if sw_result.scores_below.size() == 0: return true # Player is last :o
	var below: Dictionary = sw_result.scores_below[0]
	append_score(below.position, below.metadata.player_name, -below.score)
	return true


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
