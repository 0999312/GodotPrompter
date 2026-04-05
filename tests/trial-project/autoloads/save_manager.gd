extends Node

const SAVE_DIR := "user://saves/"
const SAVE_EXTENSION := ".json"
const CURRENT_VERSION := 1

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)

func save_game(slot_name: String = "autosave") -> bool:
	var player := get_tree().get_first_node_in_group("player")
	if not player:
		push_error("SaveManager: no player found")
		return false

	var inventory: Inventory = player.get_node_or_null("Inventory")

	var data: Dictionary = {
		"version": CURRENT_VERSION,
		"timestamp": Time.get_unix_time_from_system(),
		"player": {
			"position_x": player.global_position.x,
			"position_y": player.global_position.y,
			"health": player.health_component.current_health,
		},
		"inventory": inventory.to_save_data() if inventory else [],
		"score": GameManager.score,
	}

	var json_string := JSON.stringify(data, "\t")
	var path := SAVE_DIR + slot_name + SAVE_EXTENSION
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: cannot open '%s' for writing" % path)
		return false

	file.store_string(json_string)
	EventBus.game_saved.emit(slot_name)
	print("Game saved to %s" % path)
	return true

func load_game(slot_name: String = "autosave") -> bool:
	var path := SAVE_DIR + slot_name + SAVE_EXTENSION
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("SaveManager: no save file at '%s'" % path)
		return false

	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	if err != OK:
		push_error("SaveManager: JSON parse error: %s" % json.get_error_message())
		return false

	var data: Dictionary = json.data
	data = _migrate(data)

	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.global_position = Vector2(data["player"]["position_x"], data["player"]["position_y"])
		player.health_component.heal(data["player"]["health"] - player.health_component.current_health)

	GameManager.score = int(data["score"])

	EventBus.game_loaded.emit(slot_name)
	print("Game loaded from %s" % path)
	return true

func _migrate(data: Dictionary) -> Dictionary:
	var version: int = int(data.get("version", 0))
	data["version"] = CURRENT_VERSION
	return data

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("save_game"):
		save_game()
	elif event.is_action_pressed("load_game"):
		load_game()
