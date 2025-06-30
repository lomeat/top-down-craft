extends Node2D

signal inventory_updated(_inventory: Dictionary)

# Inventory Example
# var inv = [
# 	{
# 		item: ItemRes
# 		count: int
# 	}
# ]

var inventory := []
var inv_size := 8

func _ready() -> void:
	for i in range(inv_size):
		inventory.append({ "item": null, "count": 0})
	print("inventory logs")
	print(inventory)

func add_item(item: ItemRes, count: int = 1) -> void:
	if check_fullness():
		return
	
	if not check_item(item.id, false):
		inventory.append({ "item": item, "count": count })
		return

	var temp_slots = []
	inventory = inventory.map(func(slot):
		if slot.item and slot.item.id == item.id:
			var result_count = slot.count + count
			if result_count <= item.max_stack:
				return { "item": slot.item, "count": slot.count + count }
			else:
				var rest = count - (item.max_stack - slot.count)
				temp_slots.append({ "item": item, "count": rest })
				return { "item": item, "count": item.max_stack }
		else:
			return slot
	)
	if not temp_slots.is_empty():
		inventory.append(temp_slots[0])

	inventory_updated.emit(inventory)
	print(inventory)

func remove_item(id: String, count: int = 1) -> void:
	if not check_item(id, false):
		return
	
	var min_count = get_min_count_item(id)
	for i in range(inventory.size()):
		if inventory[i].item.id == id and inventory[i].count == min_count:
			if min_count <= 1:
				inventory.remove_at(i)
				return
			inventory[i].count -= count
			return

	inventory_updated.emit(inventory)

func get_min_count_item(id: String) -> int:
	var item = ItemDB.get_item(id)
	return inventory.reduce(func(acc, slot):
		if slot.item.id == id and slot.count <= acc:
			return slot.count
		else:
			return acc
	, item.max_stack)

func get_slots_by_item(id: String) -> Array:
	if not check_item(id): return []
	return inventory.filter(func(slot): return slot.item.id == id)

func get_items(id: String = "") -> Array:
	if id.is_empty():
		return inventory

	return get_slots_by_item(id).map(func(slot): return slot.item)

func check_fullness():
	return inventory.size() >= inv_size
	
func get_item(id: String) -> Dictionary:
	if not check_item(id):
		return {}
	
	return inventory.reduce(func(acc, slot):
		if slot.item.id == id:
			return acc.count + slot.item.count
		else:
			return acc
	, { "item": {}, "count": 0 })

func get_item_count(id: String) -> int:
	if not check_item(id):
		return 0

	# Probably need check with .has()
	return int(get_item(id).count)

func check_item(id: String, is_error: bool = true) -> bool:
	return inventory.any(func(slot):
		if slot.item:
			return slot.item.id == id
		else:
			if is_error:
				push_error("Item was not found ", id)
			return false	
	)

func clear():
	inventory.clear()
