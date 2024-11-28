extends Node

@onready var start_time: float = Time.get_unix_time_from_system()

func reset_timer() -> void:
	start_time = Time.get_unix_time_from_system()

func get_run_time() -> void:
	return snapped(Time.get_unix_time_from_system() - start_time, 0.001)
