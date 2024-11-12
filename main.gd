extends Node2D

@onready var player: Player = $Player
@onready var player_start: Node2D = $PlayerStart
@onready var speedrun_timer: Control = $GUI/MarginContainer/SpeedrunTimer
@onready var leaderboard: Control = $GUI/MarginContainer/Leaderboard
@onready var finish: Node2D = $Finish

func _ready() -> void:
	leaderboard.visible = false
	reset()


func _on_player_hit() -> void:
	reset()


func reset() -> void:
	player.global_position = player_start.global_position
	player.velocity = Vector2.ZERO
	player.unlock_control()
	finish.finished = false
	speedrun_timer.reset_timer()


func _on_finish_player_reached_finish() -> void:
	speedrun_timer.stop_timer()
	leaderboard.display_leaderboard(speedrun_timer.get_run_time())
	player.lock_control()


func _on_leaderboard_restart() -> void:
	reset()
