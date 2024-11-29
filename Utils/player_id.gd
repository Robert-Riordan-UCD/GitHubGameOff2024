class_name PlayerID
extends Node


static func get_id() -> String:
	var file: FileAccess = FileAccess.open("user://id.txt", FileAccess.READ)
	if file:
		return file.get_as_text()
	else:
		randomize()
		var new_id: String = str(randi()) + str(randi()) + str(randi()) + str(randi()) # Random enough for a game jam.
		file = FileAccess.open("user://id.txt", FileAccess.WRITE)
		file.store_string(new_id)
		return new_id
