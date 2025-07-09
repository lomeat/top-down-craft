class_name DragState
extends Node

var inventory_id: String
var slot_id: int
var item: ItemRes

func _init(_inventory_id: String = "", _slot_id: int = -1, _item: ItemRes = null):
	self.inventory_id = _inventory_id
	self.slot_id = _slot_id
	# Will be an error cos of null
	self.item = _item
	print(self.inventory_id)

func setup(_inventory_id: String, _slot_id: int, _item: ItemRes):
	self.inventory_id = _inventory_id
	self.slot_id = _slot_id
	self.item = _item

func reset():
	self.inventory_id = ""
	self.slot_id = -1
	self.item = null

# Example:
#
# var drag_state = DragState.new("player", 1, wood)
# drag_state.inventory_id = "player"
# drag_state.slot_id = 2
# drag_state._item = item
# drag_state.set("chest", 2, item)
# print(drag_state.slot_id) -> 2
# drag_state.reset()
# print(drag_state.slot_id) -> -1