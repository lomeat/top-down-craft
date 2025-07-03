class_name InventoryUI
extends CanvasLayer

@onready var grid := $UIRoot/Panel/GridContainer
@onready var root := $UIRoot

@export var inventory_id := "player"

var anim: Tween

func _ready() -> void:
	await InventoryManager.inventory_registered
	
	visible = false

	InventoryManager.inventory_updated.connect(_on_inventory_updated)
	update_ui()

	for i in range(grid.get_child_count()):
		var slot = grid.get_child(i)
		if slot is InventorySlotUI:
			slot.slot_id = i
			slot.inventory_id = inventory_id


func _on_inventory_updated(updated_id: String) -> void:
	if updated_id == inventory_id:
		update_ui()

func update_ui():
	var inv = InventoryManager.get_inv(inventory_id)
	if not inv:
		return

	for i in range(grid.get_child_count()):
		var slot = grid.get_child(i)
		if slot is InventorySlotUI:
			var item = inv.get_slot(i)
			slot.update_slot(item)

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


func _input(event: InputEvent) -> void:
	toggle(event)
