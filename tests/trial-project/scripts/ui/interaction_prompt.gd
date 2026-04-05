extends Label

func _ready() -> void:
	visible = false
	text = "Press E to interact"

func show_prompt(action_text: String = "interact") -> void:
	text = "Press E to %s" % action_text
	visible = true

func hide_prompt() -> void:
	visible = false
