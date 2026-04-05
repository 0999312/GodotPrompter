class_name HealthBar
extends ProgressBar

@export var tween_duration: float = 0.25

var _tween: Tween

func _ready() -> void:
	step = 0.0
	max_value = 100
	value = 100
	EventBus.health_changed.connect(_on_health_changed)

func _on_health_changed(current: int, maximum: int) -> void:
	max_value = maximum
	_animate_to(current)

func _animate_to(target_value: float) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_QUAD)
	_tween.tween_property(self, "value", target_value, tween_duration)
