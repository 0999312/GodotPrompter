extends Node2D

@onready var player: CharacterBody2D = $NavigationRegion2D/Player
@onready var camera: Camera2D = $GameCamera
@onready var hud: CanvasLayer = $HUD
@onready var inventory_ui = $HUD/InventoryUI
@onready var dialogue_ui = $HUD/DialogueUI

func _ready() -> void:
	# Wire camera to player
	camera.target = player

	# Wire inventory UI to player's inventory
	var inventory: Inventory = player.get_node("Inventory")
	inventory_ui.bind(inventory)

	# Wire screen shake to damage events
	EventBus.damage_dealt.connect(_on_damage_dealt)

	# Add HUD to group for NPC prompt access
	hud.add_to_group("hud")

func _on_damage_dealt(_amount: int, _position: Vector2) -> void:
	camera.add_trauma(0.3)
