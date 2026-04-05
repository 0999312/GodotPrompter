extends Node

signal dialogue_started
signal line_displayed(line: DialogueLine)
signal choice_presented(choices: Array)
signal dialogue_ended

var _data: DialogueData = null
var _current_line: DialogueLine = null
var _active: bool = false

func is_active() -> bool:
	return _active

func start_dialogue(dialogue_data: DialogueData) -> void:
	_data = dialogue_data
	_active = true
	dialogue_started.emit()
	EventBus.dialogue_started.emit()
	_go_to_line(_data.start_line_id)

func advance() -> void:
	if not _active or _current_line == null:
		return
	if not _current_line.choices.is_empty():
		return
	_go_to_line(_current_line.next_line_id)

func choose(choice_index: int) -> void:
	if not _active or _current_line == null:
		return
	if choice_index < 0 or choice_index >= _current_line.choices.size():
		return
	var next_id: String = _current_line.choices[choice_index].get("next_line_id", "")
	_go_to_line(next_id)

func _go_to_line(line_id: String) -> void:
	if line_id.is_empty():
		_end_dialogue()
		return
	_current_line = _data.get_line(line_id)
	if _current_line == null:
		push_error("DialogueManager: line '%s' not found" % line_id)
		_end_dialogue()
		return
	line_displayed.emit(_current_line)
	if not _current_line.choices.is_empty():
		choice_presented.emit(_current_line.choices)

func _end_dialogue() -> void:
	_active = false
	_current_line = null
	_data = null
	dialogue_ended.emit()
	EventBus.dialogue_ended.emit()
