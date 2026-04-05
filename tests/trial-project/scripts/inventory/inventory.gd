class_name Inventory
extends Node

signal inventory_changed
signal item_added(item: ItemData, quantity: int)
signal item_removed(item: ItemData, quantity: int)

@export var capacity: int = 12

var slots: Array[InventorySlot] = []

func _ready() -> void:
	slots.resize(capacity)
	for i in capacity:
		slots[i] = InventorySlot.new()

func add_item(item: ItemData, quantity: int = 1) -> int:
	var remaining := quantity
	for slot in slots:
		if remaining <= 0:
			break
		if not slot.is_empty() and slot.item == item:
			remaining = slot.add_to_stack(remaining)
	for slot in slots:
		if remaining <= 0:
			break
		if slot.is_empty():
			slot.item = item
			remaining = slot.add_to_stack(remaining)
	var added := quantity - remaining
	if added > 0:
		item_added.emit(item, added)
		inventory_changed.emit()
	return remaining

func remove_item(item: ItemData, quantity: int = 1) -> void:
	var remaining := quantity
	for slot in slots:
		if remaining <= 0:
			break
		if not slot.is_empty() and slot.item == item:
			var removed := mini(slot.quantity, remaining)
			slot.remove_from_stack(removed)
			remaining -= removed
	var actually_removed := quantity - remaining
	if actually_removed > 0:
		item_removed.emit(item, actually_removed)
		inventory_changed.emit()

func has_item(item_id: String) -> bool:
	for slot in slots:
		if not slot.is_empty() and slot.item.id == item_id:
			return true
	return false

func to_save_data() -> Array:
	var data: Array = []
	for slot in slots:
		if slot.is_empty():
			data.append({"id": "", "qty": 0})
		else:
			data.append({"id": slot.item.id, "qty": slot.quantity})
	return data
