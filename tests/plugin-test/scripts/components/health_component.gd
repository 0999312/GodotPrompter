# scripts/components/health_component.gd
class_name HealthComponent
extends Node

signal damaged(amount: float)
signal healed(amount: float)
signal died

@export var max_health: float = 100.0

var current_health: float


func _ready() -> void:
	current_health = max_health


func take_damage(amount: float) -> void:
	current_health = max(0.0, current_health - amount)
	damaged.emit(amount)
	if current_health <= 0.0:
		died.emit()


func heal(amount: float) -> void:
	current_health = min(max_health, current_health + amount)
	healed.emit(amount)
