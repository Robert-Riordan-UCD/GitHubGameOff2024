extends Node2D

@onready var player: PlatformerController2D = $Player
@onready var player_start: Node2D = $PlayerStart
@onready var start: Sprite2D = $Start


func _ready() -> void:
	player.global_position = player_start.global_position
	start.global_position = player_start.global_position


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()


func _on_hit_box_hit() -> void:
	player.global_position = player_start.global_position
	player.velocity = Vector2.ZERO
