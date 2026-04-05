class_name HitboxComponent
extends Area2D

@export var damage: int = 10
@export var cooldown_duration: float = 0.5

signal hit(target_hurtbox: HurtboxComponent)

var _on_cooldown: bool = false
@onready var _cooldown_timer: Timer = _build_timer()

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if _on_cooldown:
		return
	if area is not HurtboxComponent:
		return
	hit.emit(area)
	area.receive_hit(damage)
	if cooldown_duration > 0.0:
		_on_cooldown = true
		_cooldown_timer.start(cooldown_duration)

func _build_timer() -> Timer:
	var t := Timer.new()
	t.one_shot = true
	t.timeout.connect(func(): _on_cooldown = false)
	add_child(t)
	return t
