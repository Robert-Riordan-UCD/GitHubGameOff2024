extends Label

@onready var active: bool = false


func _process(_delta: float) -> void:
	if not active: return
	text = "%.2fs" % SpeedrunTimer.get_run_time()
