class_name ItemData
extends Resource

enum ItemType { WEAPON, CONSUMABLE, QUEST }

@export var id: String = ""
@export var name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var value: int = 0
@export var item_type: ItemType = ItemType.CONSUMABLE
@export var max_stack: int = 1
@export var heal_amount: int = 0
