# scripts/ui/upgrade_ui.gd
extends CanvasLayer

signal closed

@onready var health_btn: Button = $Panel/VBoxContainer/HealthRow/BuyButton
@onready var health_info: Label = $Panel/VBoxContainer/HealthRow/InfoLabel
@onready var attack_btn: Button = $Panel/VBoxContainer/AttackRow/BuyButton
@onready var attack_info: Label = $Panel/VBoxContainer/AttackRow/InfoLabel
@onready var speed_btn: Button = $Panel/VBoxContainer/SpeedRow/BuyButton
@onready var speed_info: Label = $Panel/VBoxContainer/SpeedRow/InfoLabel
@onready var close_btn: Button = $Panel/VBoxContainer/CloseButton


func _ready() -> void:
	health_btn.pressed.connect(func(): _buy(PlayerStats.health_upgrade))
	attack_btn.pressed.connect(func(): _buy(PlayerStats.attack_upgrade))
	speed_btn.pressed.connect(func(): _buy(PlayerStats.attack_speed_upgrade))
	close_btn.pressed.connect(_close)
	_refresh()


func open() -> void:
	_refresh()
	show()
	get_tree().paused = true


func _close() -> void:
	hide()
	get_tree().paused = false
	closed.emit()


func _buy(upgrade: UpgradeData) -> void:
	if PlayerStats.try_upgrade(upgrade):
		_refresh()


func _refresh() -> void:
	_update_row(health_info, health_btn, PlayerStats.health_upgrade, "+%d HP")
	_update_row(attack_info, attack_btn, PlayerStats.attack_upgrade, "+%d%% ATK")
	_update_row(speed_info, speed_btn, PlayerStats.attack_speed_upgrade, "+%d%% SPD")


func _update_row(info: Label, btn: Button, upgrade: UpgradeData, fmt: String) -> void:
	if not upgrade.can_upgrade():
		info.text = "%s Lv.%d (MAX)" % [upgrade.upgrade_name, upgrade.current_level]
		btn.text = "MAX"
		btn.disabled = true
	else:
		var bonus := int(upgrade.get_current_value() * 100) if upgrade.value_per_level < 1.0 else int(upgrade.get_current_value())
		info.text = "%s Lv.%d (%s)" % [upgrade.upgrade_name, upgrade.current_level, fmt % bonus]
		btn.text = "Buy (%d coins)" % upgrade.get_cost()
		btn.disabled = PlayerStats.coins < upgrade.get_cost()
