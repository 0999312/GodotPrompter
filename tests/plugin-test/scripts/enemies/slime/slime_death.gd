# scripts/enemies/slime/slime_death.gd
extends State


func enter() -> void:
	var slime := player as EnemyBase
	slime.hitbox.deactivate()
	slime.hurtbox.set_deferred("monitoring", false)
	slime.animation_player.play("death")
	slime.animation_player.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)
	slime.velocity = Vector2.ZERO

	EventBus.enemy_died.emit(slime.global_position, slime.coin_drop_value * slime.coin_drop_count)


func _on_animation_finished(_anim_name: StringName) -> void:
	player.queue_free()
