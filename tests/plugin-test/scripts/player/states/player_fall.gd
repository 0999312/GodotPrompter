# scripts/player/states/player_fall.gd
extends State


func enter() -> void:
	player.animation_player.play("fall")


func physics_update(delta: float) -> void:
	player.velocity.y += 980.0 * delta

	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0.0:
		player.flip(direction)
	player.velocity.x = direction * PlayerStats.move_speed

	player.move_and_slide()

	if player.is_on_floor():
		if Input.get_axis("move_left", "move_right") != 0.0:
			state_machine.transition_to("Run")
		else:
			state_machine.transition_to("Idle")


func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and player.can_coyote_jump:
		state_machine.transition_to("Jump")
	elif event.is_action_pressed("light_attack") and player.can_attack:
		state_machine.transition_to("LightAttack")
	elif event.is_action_pressed("heavy_attack") and player.can_attack:
		state_machine.transition_to("HeavyAttack")
