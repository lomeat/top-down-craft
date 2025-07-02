class_name InventoryManager
extends Node

signal drag_started(inv_item: Dictionary)
signal drag_ended()
signal slot_updated(inventory_id: String, slot_index: int, item)

# Inventories example
# {
# 	player: {
# 		0: { id: "wood", data: item, count: 12 },
# 		1: null
# 	},
# 	chest: null
# }
var inventories := {}

var init_state: Dictionary = {
	"inventory_id": "",
	"slot_id": -1,
	"item": null,
	"count": 0,
}
var drag_state := init_state

func register_inventory(id: String, data: Dictionary) -> void:
	inventories[id] = data
	print("Registered inventory: ", id)

func start_drag(inventory_id: String, slot_id: int) -> void:
	var inventory = inventories.get(inventory_id)
	if inventory and inventory.has(slot_id):
		var item = inventory[slot_id]
		if item:
			drag_state = {
				"inventory_id": inventory_id,
				"slot_id": slot_id,
				"item": item,
				"count": item.count,
			}
			drag_started.emit(item)

func end_drag(is_success: bool) -> void:
	if is_success:
		var source_inventory = inventories.get(drag_state.inventory_id)
		if source_inventory:
			source_inventory[drag_state.slot_id] = null
			slot_updated.emit(drag_state.inventory_id, drag_state.slot_id, null)

	drag_state = init_state
	drag_ended.emit()

func drop_to_slot(target_inventory_id: String, target_slot: int) -> bool:
	if drag_state.item == null:
		return false
	
	var target_inventory = inventories.get(target_inventory_id)
	if not target_inventory:
		return false

	if target_inventory[target_slot] == null:
		target_inventory[target_slot] = drag_state.item
		slot_updated.emit(target_inventory_id, target_slot, drag_state.item)
		return true
	else:
		var temp = target_inventory[target_slot]
		target_inventory[target_slot] = drag_state.item

		var source_inventory = inventories.get(drag_state.inventory_id)
		source_inventory[drag_state.slot_id] = temp

		slot_updated.emit(target_inventory_id, target_slot, drag_state.item)
		slot_updated.emit(source_inventory, drag_state.slot_id, temp)
		return true

func clear():
	inventories.clear()