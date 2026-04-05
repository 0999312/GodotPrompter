# scripts/enemies/enemy_base.gd
class_name EnemyBase
extends CharacterBody2D

@export var coin_drop_value: int = 1
@export var coin_drop_count: int = 3

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: StateMachine = $StateMachine
@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox: Hurtbox = $Hurtbox

var facing_right: bool = true


func _ready() -> void:
	hurtbox.hit_received.connect(_on_hit_received)
	health_component.died.connect(_on_died)


func flip(direction: float) -> void:
	if direction > 0 and not facing_right:
		facing_right = true
		sprite.flip_h = false
	elif direction < 0 and facing_right:
		facing_right = false
		sprite.flip_h = true


func _on_hit_received(damage: float) -> void:
	health_component.take_damage(damage)
	if health_component.current_health > 0.0:
		state_machine.transition_to("Hurt")


func _on_died() -> void:
	state_machine.transition_to("Death")
