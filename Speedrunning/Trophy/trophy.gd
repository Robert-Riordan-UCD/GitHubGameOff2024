extends Node2D

signal collected

@onready var area_2d: Area2D = $Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D

func _ready() -> void:
	animation_player.play("idle")


func _on_area_2d_body_entered(_body: Node2D) -> void:
	collected.emit()
	area_2d.set_deferred("monitoring", false)
	animation_player.play("collected")
	cpu_particles_2d.emitting = true


func reset() -> void:
	area_2d.set_deferred("monitoring", true)
	animation_player.play("idle")
	scale = Vector2(1, 1)
