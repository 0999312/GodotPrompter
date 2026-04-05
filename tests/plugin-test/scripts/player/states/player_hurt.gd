# scripts/player/states/player_hurt.gd
extends State

const KNOCKBACK_FORCE := 200.0


func enter() -> void:
	player.hitbox.deactivate()
	player.animation_player.play("hurt")
	player.animation_player.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)

	var knockback_dir := -1.0 if player.facing_right else 1.0
	player.velocity.x = knockback_dir * KNOCKBACK_FORCE
	player.velocity.y = -150.0


func physics_update(delta: float) -> void:
	player.velocity.y += 980.0 * delta
	player.velocity.x = move_toward(player.velocity.x, 0.0, 400.0 * delta)
	player.move_and_slide()


func _on_animation_finished(_anim_name: StringName) -> void:
	if player.is_on_floor():
		state_machine.transition_to("Idle")
	else:
		state_machine.transition_to("Fall")
