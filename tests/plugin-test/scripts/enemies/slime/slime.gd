# scripts/enemies/slime/slime.gd
extends EnemyBase

@export var move_speed: float = 60.0
@export var chase_speed: float = 100.0
@export var contact_damage: float = 10.0

@onready var detection_zone: Area2D = $DetectionZone
@onready var hitbox: Hitbox = $Hitbox
@onready var patrol_left: Marker2D = $PatrolPath/Left
@onready var patrol_right: Marker2D = $PatrolPath/Right

var target: Node2D = null


func _ready() -> void:
	super._ready()
	hitbox.damage = contact_damage
	hitbox.is_active = true
	hitbox.monitoring = true
	detection_zone.body_entered.connect(_on_detection_body_entered)
	detection_zone.body_exited.connect(_on_detection_body_exited)


func _on_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		target = body


func _on_detection_body_exited(body: Node2D) -> void:
	if body is Player:
		target = null
