extends Label

@export var player: Player
@export var move_hint_time: float = 10.0
@export var jump_hint_time: float = 10.0

@onready var need_move_hint: bool = true
@onready var need_jump_hint: bool = true


func _ready() -> void:
	await  get_tree().create_timer(move_hint_time).timeout
	if need_move_hint:
		fade_in()


func _process(_delta: float) -> void:
	if need_move_hint and Input.get_axis("left", "right"):
		need_move_hint = false
		dismiss_move_hint()


func _input(event: InputEvent) -> void:
	if not player.can_move: return
	if need_move_hint and (event.is_action_pressed("left") or event.is_action_pressed("right")):
		need_move_hint = false
		dismiss_move_hint()
	if need_jump_hint and event.is_action_pressed("jump"):
		need_jump_hint = false
		if not need_move_hint:
			dismiss_jump_hint()


func dismiss_move_hint() -> void:
	fade_out()
	await  get_tree().create_timer(jump_hint_time).timeout
	if need_jump_hint:
		text = "Press A or SPACE to jump"
		fade_in()


func dismiss_jump_hint() -> void:
	await fade_out()
	queue_free()


func fade_in() -> void:
	modulate = Color("FFFFFF", 0)
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color("FFFFFF", 1), 0.8)
	tween.play()
	visible = true
	await tween.finished


func fade_out() -> void:
	modulate = Color("FFFFFF", 1)
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color("FFFFFF", 0), 0.8)
	tween.play()
	await tween.finished
	visible = false
