class_name InventoryUI
extends CanvasLayer

@onready var grid := $UIRoot/Panel/GridContainer
@onready var root := $UIRoot

var slots: Array = []
var anim: Tween

func _ready() -> void:
	visible = false
	slots = grid.get_children().filter(func (child): return child is InventorySlotUI)
	InventoryData.inventory_updated.connect(update_ui)

func toggle(isOn: bool = false):
	if visible and not isOn:
		anim = create_tween()
		anim.tween_property(root, "modulate:a", 0, 0.2).set_ease(Tween.EASE_IN)
		await anim.finished
		visible = isOn || !visible
	else:
		visible = isOn || !visible
		anim = create_tween()
		anim.tween_property(root, "modulate:a", 1, 0.2).set_ease(Tween.EASE_IN)
		

func update_ui(inventory: Array):
	slots = inventory

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		toggle()
		if visible:
			var inventory = InventoryData.get_items()
			update_ui(inventory)
