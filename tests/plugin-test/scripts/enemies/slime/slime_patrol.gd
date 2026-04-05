# scripts/enemies/slime/slime_patrol.gd
extends State

var direction: float = 1.0


func enter() -> void:
	player.animation_player.play("walk")
	direction = 1.0


func physics_update(delta: float) -> void:
	player.velocity.y += 980.0 * delta

	var slime := player as EnemyBase
	var left_x: float = slime.get_node("PatrolPath/Left").global_position.x
	var right_x: float = slime.get_node("PatrolPath/Right").global_position.x

	if slime.global_position.x <= left_x:
		direction = 1.0
	elif slime.global_position.x >= right_x:
		direction = -1.0

	slime.flip(direction)
	slime.velocity.x = direction * slime.move_speed
	slime.move_and_slide()

	if slime.target != null:
		state_machine.transition_to("Chase")
