# scripts/player/states/player_death.gd
extends State


func enter() -> void:
	player.hitbox.deactivate()
	player.hurtbox.set_deferred("monitoring", false)
	player.animation_player.play("death")
	player.animation_player.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)
	player.velocity = Vector2.ZERO


func _on_animation_finished(_anim_name: StringName) -> void:
	await player.get_tree().create_timer(1.0).timeout
	player.get_tree().reload_current_scene()
