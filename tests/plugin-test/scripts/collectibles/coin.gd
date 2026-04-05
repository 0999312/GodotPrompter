# scripts/collectibles/coin.gd
class_name Coin
extends Area2D

@export var value: int = 1

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	animation_player.play("spin")


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		PlayerStats.add_coins(value)
		EventBus.coin_collected.emit(value)
		audio.play()
		set_deferred("monitoring", false)
		hide()
		await audio.finished
		queue_free()
