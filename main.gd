extends Node2D

@onready var player: Player = $Player
@onready var player_start: Node2D = $PlayerStart
@onready var speedrun_timer: Control = $GUI/MarginContainer/SpeedrunTimer
@onready var leaderboard: Control = $GUI/MarginContainer/Leaderboard
@onready var submit_score: Control = $GUI/MarginContainer/SubmitScore
@onready var finish: Node2D = $Finish

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	reset()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		reset()


func _on_player_hit() -> void:
	reset()


func reset() -> void:
	player.reset(player_start.global_position)
	finish.finished = false
	speedrun_timer.reset_timer()
	leaderboard.hide_leader_board()


func _on_finish_player_reached_finish() -> void:
	speedrun_timer.stop_timer()
	leaderboard.preload_leaderboard()
	submit_score.display(speedrun_timer.get_run_time())
	player.finished()


func _on_leaderboard_restart() -> void:
	reset()


func _on_player_start_player_started() -> void:
	speedrun_timer.reset_timer()


func _on_player_start_player_not_started() -> void:
	speedrun_timer.reset_timer()
	speedrun_timer.stop_timer()


func _on_submit_score_submit(player_name: String) -> void:
	leaderboard.display_leaderboard(speedrun_timer.get_run_time(), player_name)


func _on_submit_score_skip() -> void:
	leaderboard.display_leaderboard(speedrun_timer.get_run_time(), "Anonymous") 
