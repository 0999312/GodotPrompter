class_name DialogueLine
extends Resource

@export var id: String = ""
@export var speaker: String = ""
@export_multiline var text: String = ""
@export var choices: Array[Dictionary] = []
@export var next_line_id: String = ""
