extends Control

@onready var start_time: float = Time.get_unix_time_from_system()
@onready var label: Label = $Label
var stopped: bool = false
var stop_time: float


func _process(_delta: float) -> void:
	label.text = "%.2f s" % get_run_time()


func stop_timer():
	if stopped: return
	stop_time = get_run_time()
	stopped = true


func reset_timer():
	start_time = Time.get_unix_time_from_system()
	stopped = false


func get_run_time():
	if stopped: return stop_time
	return snapped(Time.get_unix_time_from_system() - start_time, 0.001)
