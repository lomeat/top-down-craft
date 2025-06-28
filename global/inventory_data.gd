extends Node2D

signal inventory_updated(_inventory: Dictionary)

var inventory: Dictionary = {}

func add_item(item: ItemRes, count: int = 1):
	var id = item.id
	var res = ItemDB.get_item(id)
	if not res:
		push_error("Item not found: ", id)
		return
	
	if inventory.has(id):
		inventory[id].count += count
	else:
		inventory[id] = { "data": res, "count": count }

	# check_max_stack(id, res)
	inventory_updated.emit(inventory)


func remove_item(id: String, count: int = 1) -> void:
	if inventory.has(id):
		inventory[id].count -= count
		if inventory[id].count <= 0:
			inventory.erase(id)
		inventory_updated.emit(inventory)

func get_items() -> Dictionary:
	return inventory

func get_all_items() -> Array[Dictionary]:
	return inventory.values()

func get_item(id: String) -> Dictionary:
	if check_item(id):
		return inventory.get(id)
	else:
		return {}

func get_item_count(id: String) -> int:
	if check_item(id):
		return inventory[id].count
	else:
		return 0

func check_item(id: String) -> bool:
	if inventory.has(id):
		return true
	else:
		print("Inventory has not: ", id)
		return false

func clear():
	inventory.clear()


# TODO: Make inventory can keep items with same id

# func check_max_stack(id: String, res: ItemRes):
# 	if not check_item(id) or not res: return
	
# 	if inventory[id].count > res.max_stack:
# 		var rest = inventory[id].count - res.max_stack
# 		inventory[id].count = res.max_stack
# 		add_item(res, rest)
