extends PanelContainer

@onready var grid: GridContainer = $MarginContainer/VBoxContainer/GridContainer
@onready var close_btn: Button = $MarginContainer/VBoxContainer/Header/CloseButton

var _inventory: Inventory = null

func _ready() -> void:
	visible = false
	close_btn.pressed.connect(func(): visible = false)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		visible = !visible
		if visible:
			refresh()

func bind(inventory: Inventory) -> void:
	_inventory = inventory
	_inventory.inventory_changed.connect(func(): if visible: refresh())

func refresh() -> void:
	if not _inventory:
		return
	for child in grid.get_children():
		child.queue_free()
	for slot in _inventory.slots:
		var label := Label.new()
		if slot.is_empty():
			label.text = "---"
		else:
			label.text = "%s x%d" % [slot.item.name, slot.quantity]
		label.custom_minimum_size = Vector2(120, 30)
		grid.add_child(label)
