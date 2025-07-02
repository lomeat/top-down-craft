# TODO: Remove from autoload, now its just a class
# class_name InventoryData
extends RefCounted

signal inventory_updated(_inventory: Dictionary)

### Inventory Example
# {
# 	0: {
# 		id: "wood",
# 		data: { id: "wood", name: "Just a Wood", ... },
# 		count: 12
# 	},
# 	1: null
# }
var inv: Dictionary = {}
var inv_size := 8

func _init() -> void:
	for i in range(inv_size):
		inv[i] = null

func add_item(item: ItemRes, count: int = 1) -> bool:
	var id = item.id
	var res = ItemDB.get_item(id)
	if not res:
		push_error("Item doesn't exist: ", id)
		return false

	for slot in inv:
		if inv[slot] == null:
			inv[slot] = {
				"id": id,
				"data": res,
				"count": count
			}
			inventory_updated.emit(inv)
			return true
		elif inv[slot].id == item.id:
			inv[slot].count += count
			inventory_updated.emit(inv)
	return false

func set_slot(slot_id: int, item: Dictionary) -> void:
	if slot_id < 0 or slot_id >= inv_size:
		return
	inv[slot_id] = item
	inventory_updated.emit(inv)

func remove_item(id: String, count: int = 1) -> bool:
	for slot in inv:
		if inv[slot].id == id:
			inv[slot].count -= count
			if inv[slot].count <= 0:
				remove_slot(slot)
			inventory_updated.emit(inv)
			return true
	return false

func remove_slot(slot_id: int) -> bool:
	if inv.has(slot_id) and inv[slot_id] != null:
		inv[slot_id] = null
		inventory_updated.emit(inv)
		return true
	return false

# @doc -> ItemRes{} | null
func get_item(id: String):
	for slot in inv:
		if inv[slot].id == id:
			return inv[slot]
	return null

func get_slot(slot_id: int):
	if inv.has(slot_id):
		return inv.get(slot_id)
	return null

func get_items() -> Dictionary:
	return inv

func get_item_count(id: String):
	for slot in inv:
		if inv[slot].id == id:
			return inv[slot].count
	return null

func clear():
	for i in range(inv_size):
		inv[i] = null
	inventory_updated.emit(inv)