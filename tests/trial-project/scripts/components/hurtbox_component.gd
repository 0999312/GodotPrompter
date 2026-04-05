class_name HurtboxComponent
extends Area2D

@export var health_component: HealthComponent
@export var invincibility_duration: float = 0.5

signal hurt(damage_amount: int)

var _invincible: bool = false
@onready var _iframes_timer: Timer = _build_timer()

func receive_hit(damage: int) -> void:
	if _invincible:
		return
	hurt.emit(damage)
	if health_component:
		health_component.take_damage(damage)
	if invincibility_duration > 0.0:
		_invincible = true
		_iframes_timer.start(invincibility_duration)

func _build_timer() -> Timer:
	var t := Timer.new()
	t.one_shot = true
	t.timeout.connect(func(): _invincible = false)
	add_child(t)
	return t
