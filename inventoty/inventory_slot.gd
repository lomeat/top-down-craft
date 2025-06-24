class_name InventorySlot
extends Control

@onready var item_icon := $ItemIcon
@onready var count_label := $CountLabel

func update_slot(id: String, count: int) -> void:
	if not id or id.is_empty() or count <= 0:
		clear_slot()
		return 
	
	var res = ItemDB.get_item(id)
	if res:
		item_icon.texture = res.texture
		count_label.text = str(count)

func clear_slot():
	item_icon.texture = null
	count_label.text = ""

