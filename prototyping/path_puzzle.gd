extends Sprite2D
@onready var player: PlatformerController2D = $"../../Player"

var player_near: bool = false
var code: Array[String] = ["right", "up", "right", "up", "right", "up", "up", "left", "left", "down"]
var index: int = 0

func _input(event: InputEvent) -> void:
	if !player_near or index >= code.size(): return
	var inputs: Array[String] = ["up", "right", "left", "down"]
	for input in inputs:
		if event.is_action_pressed(input):
			if code[index] == input: index += 1
			else: index = 0
			print(index)
			
			if index >= code.size():
				print("You found the secret path!")
				queue_free()
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == player: player_near = true
	index = 0


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player: player_near = false


func _on_timer_timeout() -> void:
	print("You did it!")
