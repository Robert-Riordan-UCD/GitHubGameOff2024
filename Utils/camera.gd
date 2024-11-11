extends Camera2D

@export var target: Node2D = null

func _ready() -> void:
	if target == null:
		push_error("No target assigned to camera")


func _process(_delta: float) -> void:
	global_position = target.global_position
