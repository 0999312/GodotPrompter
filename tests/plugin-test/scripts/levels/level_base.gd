# scripts/levels/level_base.gd
extends Node2D

@export var coin_scene: PackedScene


func _ready() -> void:
	EventBus.enemy_died.connect(_on_enemy_died)
	PlayerStats.heal_full()


func _on_enemy_died(pos: Vector2, total_value: int) -> void:
	for i in total_value:
		var coin := coin_scene.instantiate() as Coin
		coin.global_position = pos + Vector2(randf_range(-20, 20), randf_range(-30, -10))
		call_deferred("add_child", coin)
