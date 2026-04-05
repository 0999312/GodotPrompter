# scripts/player/player.gd
class_name Player
extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: StateMachine = $StateMachine
@onready var hitbox_pivot: Node2D = $HitboxPivot
@onready var hitbox: Hitbox = $HitboxPivot/Hitbox
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var attack_cooldown: Timer = $AttackCooldown

var facing_right: bool = true
var can_coyote_jump: bool = false
var can_attack: bool = true


func _ready() -> void:
	hurtbox.hit_received.connect(_on_hit_received)
	coyote_timer.timeout.connect(func(): can_coyote_jump = false)
	attack_cooldown.timeout.connect(func(): can_attack = true)


func flip(direction: float) -> void:
	if direction > 0 and not facing_right:
		facing_right = true
		sprite.flip_h = false
		hitbox_pivot.scale.x = 1
	elif direction < 0 and facing_right:
		facing_right = false
		sprite.flip_h = true
		hitbox_pivot.scale.x = -1


func start_coyote_time() -> void:
	can_coyote_jump = true
	coyote_timer.start()


func start_attack_cooldown() -> void:
	can_attack = false
	attack_cooldown.wait_time = 0.4 / PlayerStats.attack_speed
	attack_cooldown.start()


func _on_hit_received(damage: float) -> void:
	PlayerStats.take_damage(int(damage))
	if PlayerStats.current_health > 0:
		state_machine.transition_to("Hurt")
	else:
		state_machine.transition_to("Death")
