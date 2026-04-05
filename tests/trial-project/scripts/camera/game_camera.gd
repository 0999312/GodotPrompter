extends Camera2D

@export var target: Node2D
@export var follow_speed: float = 8.0
@export var look_ahead_distance: float = 60.0
@export var look_ahead_speed: float = 4.0

# Screen shake
var _trauma: float = 0.0
var _max_offset: float = 12.0
var _trauma_decay: float = 2.0

var _look_ahead_offset: Vector2 = Vector2.ZERO
var _previous_target_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	position_smoothing_enabled = false
	if target:
		_previous_target_pos = target.global_position
		global_position = target.global_position

func _process(delta: float) -> void:
	if not target:
		return

	var move_delta: Vector2 = target.global_position - _previous_target_pos
	_previous_target_pos = target.global_position

	var desired_ahead: Vector2 = move_delta.normalized() * look_ahead_distance if move_delta.length() > 0.5 else Vector2.ZERO
	_look_ahead_offset = _look_ahead_offset.lerp(desired_ahead, look_ahead_speed * delta)

	var desired_pos: Vector2 = target.global_position + _look_ahead_offset
	global_position = global_position.lerp(desired_pos, follow_speed * delta)

	if _trauma > 0.0:
		_trauma = maxf(_trauma - _trauma_decay * delta, 0.0)
		var shake_intensity := _trauma * _trauma
		offset = Vector2(
			randf_range(-_max_offset, _max_offset) * shake_intensity,
			randf_range(-_max_offset, _max_offset) * shake_intensity
		)
	else:
		offset = Vector2.ZERO

func add_trauma(amount: float) -> void:
	_trauma = minf(_trauma + amount, 1.0)
