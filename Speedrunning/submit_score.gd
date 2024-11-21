extends Control

signal submit(player_name: String)
signal skip

@onready var line_edit: LineEdit = $VBoxContainer/LineEdit
@onready var time: Label = $VBoxContainer/Time


func display(new_time: float) -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	time.text = str(new_time) + ' s'
	visible = true
	line_edit.grab_focus()


func _on_submit_pressed() -> void:
	if line_edit.text == "": return
	submit.emit(line_edit.text)
	line_edit.release_focus()
	visible = false


func _on_skip_pressed() -> void:
	skip.emit()
	visible = false


func _on_line_edit_text_changed(new_text: String) -> void:
	var allowed_characters = "[A-Za-z0-9 ]"
	var old_caret_position = line_edit.caret_column
	var word = ""
	var regex = RegEx.new()
	regex.compile(allowed_characters)
	for valid_character in regex.search_all(new_text):
		word += valid_character.get_string()
	line_edit.set_text(word)
	line_edit.caret_column = old_caret_position


func _on_line_edit_text_submitted(_new_text: String) -> void:
	_on_submit_pressed()
