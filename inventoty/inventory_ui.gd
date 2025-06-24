extends CanvasLayer

@onready var grid := $Panel/GridContainer

var slots: Array = []

func _ready() -> void:
	visible = false
	slots = grid.get_children().filter(func (child): return child is InventorySlot)
	InventoryData.inventory_updated.connect(update_ui)

func toggle(isOn: bool = false):
	visible = isOn || !visible

func update_ui(inventory: Dictionary):
	for slot in slots:
		slot.update_slot("", 0)
	
	var index = 0
	for id in inventory:
		if index >= slots.size():
			break
		var data = inventory[id]
		slots[index].update_slot(id, data.count)
		index += 1

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		toggle()
		if visible:
			var inventory = InventoryData.get_items()
			update_ui(inventory)