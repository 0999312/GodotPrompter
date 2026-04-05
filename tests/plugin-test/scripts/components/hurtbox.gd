# scripts/components/hurtbox.gd
class_name Hurtbox
extends Area2D

signal hit_received(damage: float)


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if area is Hitbox and area.is_active:
		hit_received.emit(area.damage)
