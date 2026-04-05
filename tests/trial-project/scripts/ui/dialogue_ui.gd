extends PanelContainer

@onready var speaker_label: Label = $MarginContainer/VBoxContainer/SpeakerLabel
@onready var text_label: RichTextLabel = $MarginContainer/VBoxContainer/TextLabel
@onready var choices_container: VBoxContainer = $MarginContainer/VBoxContainer/ChoicesContainer
@onready var continue_label: Label = $MarginContainer/VBoxContainer/ContinueLabel

func _ready() -> void:
	visible = false
	DialogueManager.line_displayed.connect(_on_line_displayed)
	DialogueManager.choice_presented.connect(_on_choice_presented)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.dialogue_started.connect(func(): visible = true)

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("attack"):
		DialogueManager.advance()

func _on_line_displayed(line: DialogueLine) -> void:
	speaker_label.text = line.speaker
	text_label.text = line.text
	for child in choices_container.get_children():
		child.queue_free()
	continue_label.visible = line.choices.is_empty()

func _on_choice_presented(choices: Array) -> void:
	continue_label.visible = false
	for i in choices.size():
		var btn := Button.new()
		btn.text = choices[i].get("text", "...")
		var idx := i
		btn.pressed.connect(func(): DialogueManager.choose(idx))
		choices_container.add_child(btn)

func _on_dialogue_ended() -> void:
	visible = false
