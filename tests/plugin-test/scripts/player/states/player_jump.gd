# scripts/player/states/player_jump.gd
extends State


func enter() -> void:
	player.velocity.y = PlayerStats.jump_velocity
	player.animation_player.play("jump")


func physics_update(delta: float) -> void:
	player.velocity.y += 980.0 * delta

	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0.0:
		player.flip(direction)
	player.velocity.x = direction * PlayerStats.move_speed

	if player.velocity.y > 0.0:
		state_machine.transition_to("Fall")
		return

	player.move_and_slide()


func handle_input(event: InputEvent) -> void:
	if event.is_action_released("jump") and player.velocity.y < 0.0:
		player.velocity.y *= 0.5
	elif event.is_action_pressed("light_attack") and player.can_attack:
		state_machine.transition_to("LightAttack")
	elif event.is_action_pressed("heavy_attack") and player.can_attack:
		state_machine.transition_to("HeavyAttack")
