class_name LeaderboardLabel
extends Label

@onready var timer: Timer = $Timer
@onready var leader_board_label: Label = $"."
@onready var on: bool = true

@export var flash: bool = false:
	set(state):
		flash = state
		if state: timer.start()


# Toggle visiblity without changing layout of surounding elements
func _on_timer_timeout() -> void:
	on = not on
	if on: leader_board_label.self_modulate = Color(127)
	else: leader_board_label.self_modulate = Color(255)
