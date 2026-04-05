# scripts/autoloads/event_bus.gd
extends Node

signal coin_collected(value: int)
signal player_died
signal enemy_died(position: Vector2, coin_value: int)
signal upgrade_purchased(upgrade_type: String, new_level: int)
