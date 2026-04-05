extends Node

signal scene_changed(scene_path: String)
signal game_paused(is_paused: bool)

var score: int = 0:
	set(value):
		score = value
		EventBus.score_changed.emit(score)

var is_paused: bool = false

func change_scene(path: String) -> void:
	scene_changed.emit(path)
	get_tree().change_scene_to_file(path)

func set_paused(paused: bool) -> void:
	is_paused = paused
	get_tree().paused = paused
	game_paused.emit(paused)

func add_score(amount: int) -> void:
	score += amount
