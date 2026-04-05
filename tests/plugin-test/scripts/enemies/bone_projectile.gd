# scripts/enemies/bone_projectile.gd
class_name BoneProjectile
extends Area2D

@export var speed: float = 250.0
@export var damage: float = 15.0

var direction: Vector2 = Vector2.RIGHT

@onready var lifetime_timer: Timer = $LifetimeTimer


func _ready() -> void:
	lifetime_timer.timeout.connect(queue_free)
	lifetime_timer.start()
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var hurtbox := body.get_node_or_null("Hurtbox") as Hurtbox
		if hurtbox:
			hurtbox.hit_received.emit(damage)
	queue_free()
