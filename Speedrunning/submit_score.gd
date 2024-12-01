extends Control

signal submit(player_name: String)
signal skip

@onready var line_edit: LineEdit = $VBoxContainer/LineEdit
@onready var time: Label = $VBoxContainer/Time


func _ready() -> void:
	var file: FileAccess = FileAccess.open("user://username.txt", FileAccess.READ)
	if file:
		line_edit.text = file.get_as_text()
		line_edit.caret_column = line_edit.text.length()


func display(new_time: float) -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	time.text = str(new_time) + ' s'
	visible = true
	line_edit.grab_focus()


func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_accept"):
		_on_submit_pressed()


func _on_submit_pressed() -> void:
	if line_edit.text == "": return
	submit.emit(line_edit.text)
	line_edit.release_focus()
	save_username(line_edit.text)
	visible = false


func save_username(username: String) -> void:
	var file: FileAccess = FileAccess.open("user://username.txt", FileAccess.WRITE)
	if file:
		file.store_string(username)


func _on_skip_pressed() -> void:
	skip.emit()
	visible = false


func _on_line_edit_text_changed(new_text: String) -> void:
	var allowed_characters: String = "[A-Za-z0-9 ]"
	var old_caret_position: int = line_edit.caret_column
	var word: String = ""
	var regex: RegEx = RegEx.new()
	regex.compile(allowed_characters)
	for valid_character in regex.search_all(new_text):
		word += valid_character.get_string()
	line_edit.set_text(word)
	line_edit.caret_column = old_caret_position


func _on_line_edit_text_submitted(_new_text: String) -> void:
	_on_submit_pressed()
