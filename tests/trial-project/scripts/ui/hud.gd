extends CanvasLayer

@onready var health_bar: ProgressBar = $MarginContainer/VBoxContainer/HealthBar
@onready var score_label: Label = $MarginContainer/VBoxContainer/ScoreLabel
@onready var interaction_prompt: Label = $InteractionPrompt

func _ready() -> void:
	EventBus.score_changed.connect(_on_score_changed)
	_on_score_changed(0)

func _on_score_changed(new_score: int) -> void:
	score_label.text = "Score: %d" % new_score
