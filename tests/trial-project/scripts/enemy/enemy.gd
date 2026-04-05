extends CharacterBody2D

enum State { IDLE, PATROL, CHASE, ATTACK, DEAD }

@export var stats: EnemyStats

var current_state: State = State.IDLE
var _attack_timer: float = 0.0
var _idle_timer: float = 0.0

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var hitbox: HitboxComponent = $AttackPivot/HitboxComponent
@onready var hurtbox: HurtboxComponent = $HurtboxComponent
@onready var sprite: ColorRect = $Sprite
@onready var attack_pivot: Node2D = $AttackPivot

var _player: Node2D = null

func _ready() -> void:
	add_to_group("enemies")
	hitbox.monitoring = false
	if stats:
		stats = stats.duplicate()
		health_component.max_health = stats.health
		health_component._current_health = stats.health
		hitbox.damage = stats.damage
	hurtbox.health_component = health_component
	health_component.died.connect(_on_died)
	hurtbox.hurt.connect(_on_hurt)
	_idle_timer = randf_range(1.0, 3.0)

func _physics_process(delta: float) -> void:
	if current_state == State.DEAD:
		return

	_player = get_tree().get_first_node_in_group("player")

	match current_state:
		State.IDLE:
			_state_idle(delta)
		State.PATROL:
			_state_patrol(delta)
		State.CHASE:
			_state_chase(delta)
		State.ATTACK:
			_state_attack(delta)

	move_and_slide()

func _state_idle(delta: float) -> void:
	velocity = Vector2.ZERO
	if _player_in_range(stats.chase_range):
		current_state = State.CHASE
		return
	_idle_timer -= delta
	if _idle_timer <= 0.0:
		var offset := Vector2(randf_range(-stats.patrol_range, stats.patrol_range), randf_range(-stats.patrol_range, stats.patrol_range))
		nav_agent.target_position = global_position + offset
		current_state = State.PATROL

func _state_patrol(delta: float) -> void:
	if _player_in_range(stats.chase_range):
		current_state = State.CHASE
		return
	if nav_agent.is_navigation_finished():
		current_state = State.IDLE
		_idle_timer = randf_range(1.0, 3.0)
		return
	var next_pos: Vector2 = nav_agent.get_next_path_position()
	velocity = (next_pos - global_position).normalized() * stats.speed

func _state_chase(delta: float) -> void:
	if not _player or not _player_in_range(stats.chase_range * 1.5):
		current_state = State.IDLE
		_idle_timer = 1.0
		return
	if _player_in_range(stats.attack_range):
		_enter_attack()
		return
	nav_agent.target_position = _player.global_position
	var next_pos: Vector2 = nav_agent.get_next_path_position()
	velocity = (next_pos - global_position).normalized() * stats.speed
	var dir := (_player.global_position - global_position).normalized()
	attack_pivot.rotation = dir.angle()

func _state_attack(delta: float) -> void:
	velocity = Vector2.ZERO
	_attack_timer -= delta
	if _attack_timer <= 0.0:
		hitbox.monitoring = false
		current_state = State.CHASE

func _enter_attack() -> void:
	current_state = State.ATTACK
	_attack_timer = stats.attack_interval
	hitbox.monitoring = true
	get_tree().create_timer(0.2).timeout.connect(func():
		if current_state == State.ATTACK:
			hitbox.monitoring = false
	)

func _player_in_range(range_dist: float) -> bool:
	if not _player:
		return false
	return global_position.distance_to(_player.global_position) < range_dist

func _on_died() -> void:
	current_state = State.DEAD
	velocity = Vector2.ZERO
	hitbox.monitoring = false
	if stats and randf() < stats.drop_chance and stats.drop_items.size() > 0:
		var drop: ItemData = stats.drop_items.pick_random()
		EventBus.item_collected.emit(drop.name)
	sprite.color = Color(0.3, 0.3, 0.3, 0.5)
	get_tree().create_timer(1.0).timeout.connect(queue_free)

func _on_hurt(damage_amount: int) -> void:
	sprite.color = Color.RED
	get_tree().create_timer(0.1).timeout.connect(func(): sprite.color = Color.INDIAN_RED)
	EventBus.damage_dealt.emit(damage_amount, global_position)
