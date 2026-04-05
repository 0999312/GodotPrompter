# scripts/enemies/skeleton/skeleton_hurt.gd
extends State

const KNOCKBACK_FORCE := 80.0


func enter() -> void:
	player.animation_player.play("hurt")
	player.animation_player.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)

	var skeleton: EnemyBase = player
	var knockback_dir := -1.0 if skeleton.facing_right else 1.0
	skeleton.velocity.x = knockback_dir * KNOCKBACK_FORCE
	skeleton.velocity.y = -80.0


func physics_update(delta: float) -> void:
	player.velocity.y += 980.0 * delta
	player.velocity.x = move_toward(player.velocity.x, 0.0, 200.0 * delta)
	player.move_and_slide()


func _on_animation_finished(_anim_name: StringName) -> void:
	state_machine.transition_to("Patrol")
