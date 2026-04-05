# scripts/enemies/skeleton/skeleton_attack.gd
extends State


func enter() -> void:
	var skeleton: EnemyBase = player
	skeleton.velocity.x = 0.0

	if skeleton.target:
		var dir := sign(skeleton.target.global_position.x - skeleton.global_position.x)
		skeleton.flip(dir)

	skeleton.animation_player.play("attack")
	skeleton.animation_player.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)


func physics_update(delta: float) -> void:
	player.velocity.y += 980.0 * delta
	player.move_and_slide()


func _on_animation_finished(_anim_name: StringName) -> void:
	player.shoot()
	state_machine.transition_to("Patrol")
