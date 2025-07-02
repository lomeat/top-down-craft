class_name InventoryUI
extends CanvasLayer

@onready var grid := $UIRoot/Panel/GridContainer
@onready var root := $UIRoot

@export var inventory_id := "player"

# Slots Example
# [
# 	{ inventory_id: "player", slot_id: 2, item: item }
# ]
var slots_ui: Array[InventorySlotUI] = []
var anim: Tween

func _ready() -> void:
	visible = false
	slots_ui = grid.get_children().filter(func (child): return child is InventorySlotUI)
	# InventoryData.inventory_updated.connect(update_ui)

	for i in range(slots_ui.size()):
		slots_ui[i].slot_id = i
		slots_ui[i].inventory_id = inventory_id 


func update_ui(inventory: Dictionary):
	for slot in slots:
		slot.update_slot("", 0)
	
	var index = 0
	for id in inventory:
		if index >= slots.size():
			break
		var data = inventory[id]
		slots[index].update_slot(id, data.count)
		index += 1

func toggle(event: InputEvent, isOn: bool = false):
	if event.is_action_pressed("toggle_inventory"):
		# Becomes insible
		if visible and not isOn:
			anim = create_tween()
			anim.tween_property(root, "modulate:a", 0, 0.2).set_ease(Tween.EASE_IN)
			await anim.finished
			visible = isOn || !visible
		# Becomes visible
		else:
			visible = isOn || !visible
			anim = create_tween()
			anim.tween_property(root, "modulate:a", 1, 0.2).set_ease(Tween.EASE_IN)
			# TODO: MAybe remove tihs
			# var inventory = InventoryData.get_items()
			# update_ui(inventory)


func _input(event: InputEvent) -> void:
	toggle(event)
