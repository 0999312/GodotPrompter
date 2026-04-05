class_name DialogueData
extends Resource

@export var start_line_id: String = ""
@export var lines: Array[DialogueLine] = []

func get_line(line_id: String) -> DialogueLine:
	for line in lines:
		if line.id == line_id:
			return line
	return null
