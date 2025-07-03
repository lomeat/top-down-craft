# class_name DragItem
extends Control

@onready var icon: TextureRect = $Icon
@onready var label: Label = $Label

func _ready() -> void:
	visible = false
	icon.texture = null
	label.text = ""
	
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 1000

	InventoryManager.drag_started.connect(func(_id, count, texture): show_item(count, texture))
	InventoryManager.drag_ended.connect(func(_is): hide_item())

func show_item(count, texture) -> void:
	visible = true
	icon.texture = texture
	label.text = str(count) if count > 1 else ""

func hide_item() -> void:
	icon.texture = null
	label.text = ""
	visible = false

func _process(_delta: float) -> void:
	if visible:
		global_position = get_global_mouse_position() + Vector2(16, 16)
