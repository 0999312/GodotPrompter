# scripts/enemies/skeleton/skeleton.gd
extends EnemyBase

@export var move_speed: float = 40.0
@export var attack_range: float = 200.0
@export var projectile_scene: PackedScene

@onready var detection_zone: Area2D = $DetectionZone
@onready var projectile_spawn: Marker2D = $ProjectileSpawn
@onready var attack_cooldown: Timer = $AttackCooldown

var target: Node2D = null
var can_attack: bool = true


func _ready() -> void:
	super._ready()
	detection_zone.body_entered.connect(_on_detection_body_entered)
	detection_zone.body_exited.connect(_on_detection_body_exited)
	attack_cooldown.timeout.connect(func(): can_attack = true)


func _on_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		target = body


func _on_detection_body_exited(body: Node2D) -> void:
	if body is Player:
		target = null


func shoot() -> void:
	if projectile_scene == null:
		return
	var projectile := projectile_scene.instantiate() as BoneProjectile
	projectile.global_position = projectile_spawn.global_position
	var dir := sign(target.global_position.x - global_position.x)
	projectile.direction = Vector2(dir, 0)
	get_tree().current_scene.add_child(projectile)
	can_attack = false
	attack_cooldown.start()
