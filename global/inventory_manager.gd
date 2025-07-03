# Autoload
# class_name InventoryManager
extends Node

signal drag_started(item_id: String, count: int, texture: Texture2D)
signal drag_ended(isDropped: bool)
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

# Where mouse cursor hover	
var current_slot: InventorySlotUI = null
var current_inventory_id: String = ""

# --- Main methods ---

func register_inventory(id: String, inventory: InventoryData) -> void:
	inventories[id] = inventory
	inventory.inventory_updated.connect(func (_inv):
		inventory_updated.emit(id)
	)
	inventory_registered.emit(id)
	print("Registered inventory: ", id)

func get_inv(inventory_id: String) -> InventoryData:
	return inventories.get(inventory_id)

func delete_inv(inventory_id: String) -> bool:
	if inventories.has(inventory_id):
		inventories.erase(inventory_id)
		return true
	return false

func clear():
	inventories.clear()

# --- Drag & Drop ---

func start_drag(inventory_id: String, slot_id: int) -> void:
	var inv = inventories.get(inventory_id)
	if not inv: return

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
	

func end_drag(isDropped: bool, ids: Array[String] = []) -> void:
	drag_state = {}
	drag_ended.emit(isDropped)
	current_slot = null
	if not ids.is_empty():
		for id in ids:
			inventory_updated.emit(id)

func drop_to_slot(target_inventory_id: String, target_slot_id: int) -> bool:	
	if not drag_state or drag_state.item == null: return false

	var source_inventory: InventoryData = get_inv(drag_state.inventory_id)
	var target_inventory: InventoryData = get_inv(target_inventory_id)
	if not source_inventory or not target_inventory: return false

	var source_slot = drag_state.item
	var target_slot = target_inventory.get_slot(target_slot_id)

	if drag_state.inventory_id == target_inventory_id and drag_state.slot_id == target_slot_id:
		end_drag(false, [drag_state.inventory_id])
		return false

	if not target_slot:
		target_inventory.set_slot(target_slot_id, source_slot)
		source_inventory.remove_slot(drag_state.slot_id)
		end_drag(true, [target_inventory_id, drag_state.inventory_id])
		return true
	else:
		var temp = target_slot
		target_inventory.set_slot(target_slot_id, source_slot)
		source_inventory.set_slot(drag_state.slot_id, temp)
		end_drag(true, [target_inventory_id, drag_state.inventory_id])
		return true


# --- Input D&D ----

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.is_pressed() and not drag_state.is_empty():
		match event.button_index:
			MOUSE_BUTTON_RIGHT:
				end_drag(false)
			MOUSE_BUTTON_LEFT:
				if current_slot:
					drop_to_slot(current_inventory_id, current_slot.slot_id)
				else:
					end_drag(false)