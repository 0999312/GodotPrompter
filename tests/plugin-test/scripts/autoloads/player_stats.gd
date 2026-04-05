# scripts/autoloads/player_stats.gd
extends Node

signal health_changed(current: int, maximum: int)
signal coins_changed(total: int)
signal stats_changed

var max_health: int = 100
var current_health: int = 100
var base_attack: float = 10.0
var attack_multiplier: float = 1.0
var heavy_attack_multiplier: float = 2.5
var attack_speed: float = 1.0
var move_speed: float = 200.0
var jump_velocity: float = -400.0
var coins: int = 0

var health_upgrade: UpgradeData
var attack_upgrade: UpgradeData
var attack_speed_upgrade: UpgradeData


func _ready() -> void:
	health_upgrade = UpgradeData.new()
	health_upgrade.upgrade_name = "Health"
	health_upgrade.base_cost = 10
	health_upgrade.value_per_level = 20.0

	attack_upgrade = UpgradeData.new()
	attack_upgrade.upgrade_name = "Attack"
	attack_upgrade.base_cost = 15
	attack_upgrade.value_per_level = 0.2

	attack_speed_upgrade = UpgradeData.new()
	attack_speed_upgrade.upgrade_name = "Attack Speed"
	attack_speed_upgrade.base_cost = 20
	attack_speed_upgrade.value_per_level = 0.15


func get_light_damage() -> float:
	return base_attack * attack_multiplier


func get_heavy_damage() -> float:
	return base_attack * attack_multiplier * heavy_attack_multiplier


func add_coins(amount: int) -> void:
	coins += amount
	coins_changed.emit(coins)


func take_damage(amount: int) -> void:
	current_health = max(0, current_health - amount)
	health_changed.emit(current_health, max_health)
	if current_health <= 0:
		EventBus.player_died.emit()


func heal_full() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)


func try_upgrade(upgrade: UpgradeData) -> bool:
	if not upgrade.can_upgrade():
		return false
	var cost := upgrade.get_cost()
	if coins < cost:
		return false

	coins -= cost
	upgrade.current_level += 1
	coins_changed.emit(coins)

	if upgrade == health_upgrade:
		max_health += int(upgrade.value_per_level)
		current_health += int(upgrade.value_per_level)
		health_changed.emit(current_health, max_health)
	elif upgrade == attack_upgrade:
		attack_multiplier += upgrade.value_per_level
	elif upgrade == attack_speed_upgrade:
		attack_speed += upgrade.value_per_level

	stats_changed.emit()
	EventBus.upgrade_purchased.emit(upgrade.upgrade_name, upgrade.current_level)
	return true
