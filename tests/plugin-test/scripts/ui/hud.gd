# scripts/ui/hud.gd
extends CanvasLayer

@onready var health_bar: ProgressBar = $MarginContainer/HBoxContainer/HealthBar
@onready var health_label: Label = $MarginContainer/HBoxContainer/HealthBar/Label
@onready var coin_label: Label = $MarginContainer/HBoxContainer/CoinLabel


func _ready() -> void:
	PlayerStats.health_changed.connect(_on_health_changed)
	PlayerStats.coins_changed.connect(_on_coins_changed)
	_on_health_changed(PlayerStats.current_health, PlayerStats.max_health)
	_on_coins_changed(PlayerStats.coins)


func _on_health_changed(current: int, maximum: int) -> void:
	health_bar.max_value = maximum
	health_bar.value = current
	health_label.text = "%d / %d" % [current, maximum]


func _on_coins_changed(total: int) -> void:
	coin_label.text = "Coins: %d" % total
