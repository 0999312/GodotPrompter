class_name HealthComponent
extends Node

signal health_changed(current: int, maximum: int)
signal died

@export var max_health: int = 100

var current_health: int:
	get:
		return _current_health

var _current_health: int

func _ready() -> void:
	_current_health = max_health

func take_damage(amount: int) -> void:
	_current_health = maxi(_current_health - amount, 0)
	health_changed.emit(_current_health, max_health)
	if _current_health <= 0:
		died.emit()

func heal(amount: int) -> void:
	_current_health = mini(_current_health + amount, max_health)
	health_changed.emit(_current_health, max_health)

func get_health_percent() -> float:
	if max_health <= 0:
		return 0.0
	return float(_current_health) / float(max_health)
