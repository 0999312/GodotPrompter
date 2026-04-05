# scripts/player/states/player_heavy_attack.gd
extends State


func enter() -> void:
	player.velocity.x = 0.0
	player.hitbox.activate(PlayerStats.get_heavy_damage())
	player.animation_player.play("heavy_attack")
	player.animation_player.speed_scale = PlayerStats.attack_speed * 0.7
	player.animation_player.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)
	player.start_attack_cooldown()


func exit() -> void:
	player.hitbox.deactivate()
	player.animation_player.speed_scale = 1.0


func physics_update(delta: float) -> void:
	player.velocity.y += 980.0 * delta
	player.move_and_slide()


func _on_animation_finished(_anim_name: StringName) -> void:
	if player.is_on_floor():
		state_machine.transition_to("Idle")
	else:
		state_machine.transition_to("Fall")
