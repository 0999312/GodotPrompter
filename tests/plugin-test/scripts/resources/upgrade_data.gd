# scripts/resources/upgrade_data.gd
class_name UpgradeData
extends Resource

@export var upgrade_name: String
@export var base_cost: int = 10
@export var cost_scaling: float = 1.5
@export var max_level: int = 5
@export var value_per_level: float = 0.2

var current_level: int = 0


func get_cost() -> int:
	return int(base_cost * pow(cost_scaling, current_level))


func can_upgrade() -> bool:
	return current_level < max_level


func get_current_value() -> float:
	return value_per_level * current_level
