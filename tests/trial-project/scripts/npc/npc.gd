extends StaticBody2D

@export var dialogue_data: DialogueData
@export var npc_name: String = "NPC"

var _player_nearby: bool = false

@onready var interaction_area: Area2D = $InteractionArea

func _ready() -> void:
	add_to_group("npcs")
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)
	if not dialogue_data:
		dialogue_data = NpcGreetingDialogue.create()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and _player_nearby and not DialogueManager.is_active():
		if dialogue_data:
			DialogueManager.start_dialogue(dialogue_data)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_nearby = true
		var hud := get_tree().get_first_node_in_group("hud")
		if hud:
			hud.get_node("InteractionPrompt").show_prompt("talk")

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_nearby = false
		var hud := get_tree().get_first_node_in_group("hud")
		if hud:
			hud.get_node("InteractionPrompt").hide_prompt()
