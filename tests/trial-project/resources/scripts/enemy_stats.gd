class_name EnemyStats
extends Resource

@export_group("Combat")
@export_range(1, 5000, 1) var health: int = 100
@export_range(0.0, 500.0, 0.1) var speed: float = 80.0
@export_range(0, 999, 1) var damage: int = 10
@export_range(0.1, 10.0, 0.1) var attack_interval: float = 1.5

@export_group("AI")
@export_range(0.0, 500.0, 1.0) var chase_range: float = 200.0
@export_range(0.0, 200.0, 1.0) var attack_range: float = 40.0
@export_range(0.0, 500.0, 1.0) var patrol_range: float = 150.0

@export_group("Drops")
@export var drop_items: Array[ItemData] = []
@export_range(0.0, 1.0, 0.01) var drop_chance: float = 0.3
