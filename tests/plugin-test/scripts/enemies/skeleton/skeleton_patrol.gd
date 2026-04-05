# scripts/enemies/skeleton/skeleton_patrol.gd
extends State

var direction: float = 1.0
var left_bound: float
var right_bound: float


func enter() -> void:
	player.animation_player.play("walk")
	left_bound = player.global_position.x - 80.0
	right_bound = player.global_position.x + 80.0


func physics_update(delta: float) -> void:
	player.velocity.y += 980.0 * delta

	var skeleton: EnemyBase = player

	if skeleton.global_position.x <= left_bound:
		direction = 1.0
	elif skeleton.global_position.x >= right_bound:
		direction = -1.0

	skeleton.flip(direction)
	skeleton.velocity.x = direction * skeleton.move_speed
	skeleton.move_and_slide()

	if skeleton.target != null:
		var dist := abs(skeleton.target.global_position.x - skeleton.global_position.x)
		if dist <= skeleton.attack_range and skeleton.can_attack:
			state_machine.transition_to("Attack")
