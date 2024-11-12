extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var player_start: Node2D = $PlayerStart
@onready var speedrun_timer: Control = $GUI/MarginContainer/SpeedrunTimer

func _ready() -> void:
	reset()


func _on_player_hit() -> void:
	reset()


func reset() -> void:
	player.global_position = player_start.global_position
	player.velocity = Vector2.ZERO


func _on_finish_player_reached_finish() -> void:
	speedrun_timer.stop_timer()
	player.lock_control()
