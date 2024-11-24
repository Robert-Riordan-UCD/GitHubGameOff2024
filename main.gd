extends Node2D

@onready var player: Player = $Player
@onready var player_start: Node2D = $PlayerStart
@onready var speedrun_timer: Control = $GUI/MarginContainer/SpeedrunTimer
@onready var leaderboard: Control = $GUI/MarginContainer/Leaderboard
@onready var submit_score: Control = $GUI/MarginContainer/SubmitScore
@onready var finish: Node2D = $Finish
@onready var trophies: Node2D = $Trophies

@onready var trophy_count: int = 0

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
	speedrun_timer.stop_timer()
	leaderboard.hide_leader_board()
	submit_score.visible = false
	for t in trophies.get_children():
		t.reset()
	trophy_count = 0


func _on_finish_player_reached_finish() -> void:
	speedrun_timer.stop_timer()
	leaderboard.preload_leaderboard(trophy_count)
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
	leaderboard.display_leaderboard(speedrun_timer.get_run_time(), player_name, trophy_count)


func _on_submit_score_skip() -> void:
	leaderboard.display_leaderboard(speedrun_timer.get_run_time(), "Anonymous", trophy_count)


func _on_trophy_collected() -> void:
	trophy_count += 1
	trophy_count = clamp(trophy_count, 0, 3)
