class_name InventorySlot
extends Control

@onready var item_icon := $ItemIcon
@onready var count_label := $CountLabel

var anim: Tween

func update_slot(id: String, count: int) -> void:
	if not id or id.is_empty() or count <= 0:
		clear_slot()
		return 
	
	var res = ItemDB.get_item(id)
	if res:
		item_icon.texture = res.texture
		count_label.text = str(count)

	item_icon.scale = Vector2(0.6, 0.6)
	anim = create_tween()
	anim.tween_property(item_icon, "scale", Vector2(1.1, 1.1), 0.1).set_ease(Tween.EASE_IN)
	anim.tween_property(item_icon, "scale", Vector2.ONE, 0.1).set_ease(Tween.EASE_IN)
	# anim.tween_property(item_icon, "modulate:a", 1, 0.2)
	await anim.finished

func clear_slot():
	item_icon.texture = null
	count_label.text = ""
