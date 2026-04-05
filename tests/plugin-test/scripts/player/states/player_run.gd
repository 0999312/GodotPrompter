# scripts/player/states/player_run.gd
extends State


func enter() -> void:
	player.animation_player.play("run")


func physics_update(delta: float) -> void:
	player.velocity.y += 980.0 * delta

	var direction := Input.get_axis("move_left", "move_right")
	if direction == 0.0:
		state_machine.transition_to("Idle")
		return

	player.flip(direction)
	player.velocity.x = direction * PlayerStats.move_speed

	if not player.is_on_floor():
		player.start_coyote_time()
		state_machine.transition_to("Fall")
		return

	player.move_and_slide()


func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and player.is_on_floor():
		state_machine.transition_to("Jump")
	elif event.is_action_pressed("light_attack") and player.can_attack:
		state_machine.transition_to("LightAttack")
	elif event.is_action_pressed("heavy_attack") and player.can_attack:
		state_machine.transition_to("HeavyAttack")
