extends Area2D

@export var item: ItemData
@export var quantity: int = 1

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	var inventory: Inventory = body.get_node_or_null("Inventory")
	if not inventory:
		return
	var leftover := inventory.add_item(item, quantity)
	if leftover < quantity:
		GameManager.add_score(item.value)
		if leftover <= 0:
			queue_free()
		else:
			quantity = leftover
