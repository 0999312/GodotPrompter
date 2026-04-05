extends Node

# Player events
signal player_died
signal health_changed(current: int, maximum: int)

# Combat events
signal damage_dealt(amount: int, position: Vector2)

# Score / progression
signal score_changed(new_score: int)
signal item_collected(item_name: String)

# Dialogue events
signal dialogue_started
signal dialogue_ended

# Save/Load events
signal game_saved(slot_name: String)
signal game_loaded(slot_name: String)
