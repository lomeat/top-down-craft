extends Node2D

signal inventory_updated(_inventory: Dictionary)

var inventory: Dictionary = {}


func add_item(item: ItemResource, count: int = 1):
	var id = item.id
	var res = ItemDB.get_item(id)
	if not res:
		push_error("Item not found: ", id)
		return
	
	if inventory.has(id):
		inventory[id].count += count
	else:
		inventory[id] = { "data": res, "count": count }

	check_max_stack(id, res)
	inventory_updated.emit(inventory)


func remove_item(id: String, count: int = 1):
	if inventory.has(id):
		inventory[id].count -= count
		if inventory[id].count <= 0:
			inventory.erase(id)
		inventory_updated.emit(inventory)

func get_items() -> Dictionary:
	return inventory

func get_item(id: String) -> Dictionary:
	return inventory[id] if inventory.has(id) else {}

func check_item(id: String) -> bool:
	return inventory.has(id)

func clear():
	inventory = {}

# --- Utils ---

func check_max_stack(id: String, res: ItemResource):
	if inventory[id].count > res.max_stack:
		var rest = inventory[id].count - res.max_stack
		inventory[id].count = res.max_stack
		add_item(res, rest)