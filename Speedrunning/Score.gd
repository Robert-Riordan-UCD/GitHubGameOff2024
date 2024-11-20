class_name Score
extends Node

var player_name: String
var score: float
var is_user: bool

func _init(_player_name: String, _score: float, _is_user: bool = false) -> void:
	player_name = _player_name
	score = _score
	is_user = _is_user
