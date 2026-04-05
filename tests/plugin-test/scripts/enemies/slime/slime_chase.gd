# scripts/enemies/slime/slime_chase.gd
extends State


func enter() -> void:
	player.animation_player.play("walk")


func physics_update(delta: float) -> void:
	player.velocity.y += 980.0 * delta

	var slime := player as EnemyBase
	if slime.target == null:
		state_machine.transition_to("Patrol")
		return

	var direction := sign(slime.target.global_position.x - slime.global_position.x)
	slime.flip(direction)
	slime.velocity.x = direction * slime.chase_speed
	slime.move_and_slide()
