extends Control

@onready var loading: Label = $HBoxContainer/VBoxContainer/Loading
@onready var leadboard_table: GridContainer = $HBoxContainer/VBoxContainer/LeadboardTable
const LEADER_BOARD_LABEL = preload("res://Speedrunning/leader_board_label.tscn")

func display_leaderboard() -> void:
	visible = true
	var sw_result: Dictionary = await SilentWolf.Scores.get_scores().sw_get_scores_complete
	# TODO: Handle error result
	var scores = sw_result.scores
	var rank: int = 1
	for score in scores:
		append_score(rank, score.player_name, -score.score)
		print("Player name: " + str(score.player_name) + ", score: " + str(score.score))# + ", metadata: " + str(score.metadata))
		rank += 1
	insert_buffer()
	leadboard_table.visible = true
	loading.visible = false


func append_score(rank: int, player_name: String, score: float) -> void:
	var rank_label: Label = LEADER_BOARD_LABEL.instantiate()
	rank_label.text = str(rank)
	leadboard_table.add_child(rank_label)
	
	var name_label: Label = LEADER_BOARD_LABEL.instantiate()
	name_label.text = player_name
	leadboard_table.add_child(name_label)
	
	var score_label: Label = LEADER_BOARD_LABEL.instantiate()
	score_label.text = str(score)
	leadboard_table.add_child(score_label)


func insert_buffer() -> void:
	var rank_label: Label = LEADER_BOARD_LABEL.instantiate()
	leadboard_table.add_child(rank_label)
	
	var name_label: Label = LEADER_BOARD_LABEL.instantiate()
	name_label.text = '...'
	leadboard_table.add_child(name_label)
	
	var score_label: Label = LEADER_BOARD_LABEL.instantiate()
	leadboard_table.add_child(score_label)
