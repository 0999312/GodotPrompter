class_name InventorySlot
extends RefCounted

var item: ItemData = null
var quantity: int = 0

func is_empty() -> bool:
	return item == null or quantity <= 0

func add_to_stack(amount: int) -> int:
	if item == null:
		return amount
	var can_add := mini(amount, item.max_stack - quantity)
	quantity += can_add
	return amount - can_add

func remove_from_stack(amount: int) -> void:
	quantity -= amount
	if quantity <= 0:
		item = null
		quantity = 0
