extends Sprite2D

@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var player: PlatformerController2D = $"../../Player"
@onready var area_2d: Area2D = $Area2D
@onready var timer: Timer = $Timer

var player_near: bool = false

func _process(_delta: float) -> void:
	if !player_near: return
	
	if timer.is_stopped():
		if Input.is_action_pressed("left") and Input.is_action_pressed("right"):
			timer.start()
	else:
		if not Input.is_action_pressed("left") or not Input.is_action_pressed("right"):
			timer.stop()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == player:
		player_near = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		player_near = false


func _on_timer_timeout() -> void:
	print("You did it!")
	queue_free()
