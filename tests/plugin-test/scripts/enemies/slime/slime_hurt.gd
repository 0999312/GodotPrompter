# scripts/enemies/slime/slime_hurt.gd
extends State

const KNOCKBACK_FORCE := 100.0


func enter() -> void:
	player.animation_player.play("hurt")
	player.animation_player.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)

	var slime := player as EnemyBase
	var knockback_dir := -1.0 if slime.facing_right else 1.0
	slime.velocity.x = knockback_dir * KNOCKBACK_FORCE
	slime.velocity.y = -100.0


func physics_update(delta: float) -> void:
	player.velocity.y += 980.0 * delta
	player.velocity.x = move_toward(player.velocity.x, 0.0, 300.0 * delta)
	player.move_and_slide()


func _on_animation_finished(_anim_name: StringName) -> void:
	state_machine.transition_to("Patrol")
