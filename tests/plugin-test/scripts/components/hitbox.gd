# scripts/components/hitbox.gd
class_name Hitbox
extends Area2D

@export var damage: float = 10.0

var is_active: bool = false


func activate(attack_damage: float) -> void:
	damage = attack_damage
	is_active = true
	monitoring = true


func deactivate() -> void:
	is_active = false
	monitoring = false
