# scripts/interactables/upgrade_station.gd
extends StaticBody2D

@onready var interaction_area: Area2D = $InteractionArea
@onready var prompt_label: Label = $PromptLabel
@onready var upgrade_ui: CanvasLayer = $UpgradeUI

var player_nearby: bool = false


func _ready() -> void:
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)
	prompt_label.hide()


func _unhandled_input(event: InputEvent) -> void:
	if player_nearby and event.is_action_pressed("interact"):
		upgrade_ui.open()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_nearby = true
		prompt_label.show()


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_nearby = false
		prompt_label.hide()
