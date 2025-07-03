# Autoload
# class_name InventoryManager
extends Node

signal drag_started(item_id: String, count: int, texture: Texture2D)
signal drag_ended(success: bool)
signal inventory_updated(id: String)
signal inventory_registered(id: String)

# Inventories example
# {
# 	player: {
# 		0: { id: "wood", data: item, count: 12 },
# 		1: null
# 	},
# 	chest: null
# }
var inventories := {}

# var init_state: Dictionary = {
# 	"inventory_id": "",
# 	"slot_id": -1,
# 	"item": null,
# }
var drag_state := {}

func register_inventory(id: String, inventory: InventoryData) -> void:
	inventories[id] = inventory
	inventory.inventory_updated.connect(func (_inv):
		inventory_updated.emit(id)
	)
	inventory_registered.emit(id)
	print("Registered inventory: ", id)

func start_drag(inventory_id: String, slot_id: int) -> void:
	var inv = inventories.get(inventory_id)
	if not inv:
		return

	var slot = inv.get_slot(slot_id)
	if slot:
		drag_state = {
			"inventory_id": inventory_id,
			"slot_id": slot_id,
			"item": slot,
		}
		drag_started.emit(slot.id, slot.count, slot.data.texture)
	else:
		push_error("Invalid slot_id for start_drag()")
	

func end_drag(is_success: bool) -> void:
	drag_state = {}
	drag_ended.emit(is_success)

func get_inv(inventory_id: String) -> InventoryData:
	return inventories.get(inventory_id)

func delete_inv(inventory_id: String) -> bool:
	if inventories.has(inventory_id):
		inventories.erase(inventory_id)
		return true
	return false

func drop_to_slot(target_inventory_id: String, target_slot_id: int) -> bool:
	if drag_state.item == null:
		return false

	var source_inventory: InventoryData = get_inv(drag_state.inventory_id)
	var target_inventory: InventoryData = get_inv(target_inventory_id)

	if not source_inventory or not target_inventory:
		return false

	var source_slot: Dictionary = drag_state.item
	var target_slot: Dictionary = target_inventory.get_slot(target_slot_id)

	if target_slot == null:
		target_inventory.set_slot(target_slot_id, source_slot)
		source_inventory.remove_slot(drag_state.slot_id)
		return true
	else:
		var temp = target_slot
		target_inventory.set_slot(target_slot_id, source_slot)
		source_inventory.set_slot(drag_state.slot_id, temp)
		return true

func clear():
	inventories.clear()

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT and not drag_state.is_empty():
			end_drag(false)