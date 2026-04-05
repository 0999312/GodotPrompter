extends CharacterBody2D

enum State { IDLE, MOVE, ATTACK }

@export var speed: float = 200.0
@export var acceleration: float = 1500.0
@export var friction: float = 1200.0
@export var attack_duration: float = 0.3

var current_state: State = State.IDLE
var _attack_timer: float = 0.0

@onready var health_component: HealthComponent = $HealthComponent
@onready var hitbox: HitboxComponent = $AttackPivot/HitboxComponent
@onready var hurtbox: HurtboxComponent = $HurtboxComponent
@onready var attack_pivot: Node2D = $AttackPivot
@onready var sprite: ColorRect = $Sprite

func _ready() -> void:
	add_to_group("player")
	hitbox.monitoring = false
	health_component.health_changed.connect(_on_health_changed)
	health_component.died.connect(_on_died)
	hurtbox.hurt.connect(_on_hurt)

func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			_state_idle(delta)
		State.MOVE:
			_state_move(delta)
		State.ATTACK:
			_state_attack(delta)
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack") and current_state != State.ATTACK:
		_enter_attack()

func _state_idle(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir != Vector2.ZERO:
		current_state = State.MOVE

func _state_move(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir == Vector2.ZERO:
		current_state = State.IDLE
		return
	velocity = velocity.move_toward(input_dir * speed, acceleration * delta)
	attack_pivot.rotation = input_dir.angle()

func _state_attack(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	_attack_timer -= delta
	if _attack_timer <= 0.0:
		hitbox.monitoring = false
		current_state = State.IDLE

func _enter_attack() -> void:
	current_state = State.ATTACK
	_attack_timer = attack_duration
	hitbox.monitoring = true

func _on_health_changed(current: int, maximum: int) -> void:
	EventBus.health_changed.emit(current, maximum)

func _on_died() -> void:
	EventBus.player_died.emit()
	set_physics_process(false)

func _on_hurt(damage_amount: int) -> void:
	EventBus.damage_dealt.emit(damage_amount, global_position)
	sprite.color = Color.RED
	get_tree().create_timer(0.15).timeout.connect(func(): sprite.color = Color.DODGER_BLUE)
