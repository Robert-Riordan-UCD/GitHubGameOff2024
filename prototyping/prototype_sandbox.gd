extends Node2D

@onready var player: PlatformerController2D = $Player
@onready var player_start: Node2D = $PlayerStart
@onready var start: Sprite2D = $Start


func _ready() -> void:
	_restart()
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	
	if event.is_action_pressed("restart"):
		_restart()


func _on_hit_box_hit() -> void:
	_restart()


func _restart():
	player.global_position = player_start.global_position
	player.velocity = Vector2.ZERO
	start.global_position = player_start.global_position
