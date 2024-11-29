class_name Checkpoint
extends Node2D

signal reached(checkpoint: Checkpoint)

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D
@onready var activated: bool = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		reached.emit(self)
		if not activated:
			appear()
		activated = true


func appear() -> void:
	visible = true
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(sprite_2d, "rotation", 0, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.play()
	cpu_particles_2d.emitting = true


func reset() -> void:
	sprite_2d.rotation_degrees = 90
	activated = false
	visible = false
