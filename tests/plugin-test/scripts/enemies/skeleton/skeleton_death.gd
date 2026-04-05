# scripts/enemies/skeleton/skeleton_death.gd
extends State


func enter() -> void:
	var skeleton: EnemyBase = player
	skeleton.hurtbox.set_deferred("monitoring", false)
	skeleton.animation_player.play("death")
	skeleton.animation_player.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)
	skeleton.velocity = Vector2.ZERO

	EventBus.enemy_died.emit(skeleton.global_position, skeleton.coin_drop_value * skeleton.coin_drop_count)


func _on_animation_finished(_anim_name: StringName) -> void:
	player.queue_free()
