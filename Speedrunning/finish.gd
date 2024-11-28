extends Node2D

signal player_reached_finish

@onready var finished: bool = false
@onready var particles: Node2D = $Particles


func _on_area_2d_body_entered(body: Node2D) -> void:
	if finished: return
	if body is Player and not body.dead:
		player_reached_finish.emit()
		finished = true
		for particle: RestartingParticles in particles.get_children():
			particle.emit = true
			await get_tree().create_timer(0.05).timeout


func reset() -> void:
	finished = false
	for particle: RestartingParticles in particles.get_children():
		particle.emit = false
