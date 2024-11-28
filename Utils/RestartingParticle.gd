class_name RestartingParticles
extends CPUParticles2D

@export var emit: bool = false:
	get:
		return emit
	set(value):
		emit = value
		if emit:
			emit_particles()
@export var min_delay_time: float = 0
@export var max_delay_time: float = 0.8


func _ready() -> void:
	randomize()
	finished.connect(_finished)


func emit_particles() -> void:
	if emit:
		emitting = true
		restart()


func _finished() -> void:
	var time: float = randf_range(min_delay_time, max_delay_time)
	await get_tree().create_timer(time).timeout
	emit_particles()
