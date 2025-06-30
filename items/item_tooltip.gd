class_name ItemTooltip
extends CanvasLayer

@onready var name_label := $UIRoot/Panel/MarginContainer/VBoxContainer/Name
@onready var desc_label := $UIRoot/Panel/MarginContainer/VBoxContainer/Description
@onready var root = $UIRoot

func _ready() -> void:
	root.visible = false
	root.z_index = 2
	
	if not name_label:
		name_label = $UIRoot/PanelContainer/MarginContainer/VBoxContainer/Name
	if not desc_label:
		desc_label = $UIRoot/PanelContainer/MarginContainer/VBoxContainer/Description

func setup(item_res: ItemRes):
	if not name_label and desc_label:
		await ready
	
	name_label.text = item_res.name
	desc_label.text = item_res.desc + "\n\n"

	var stats = item_res.get_stats()
	for id in stats:
		desc_label.text += id + ": " + str(stats[id]) + "\n"

func show_at_position(pos: Vector2):
	root.visible = true
	var tooltip_size = $UIRoot/PanelContainer.size
	var viewport_size = get_viewport().size

	root.position = pos
	if pos.x + tooltip_size.x > viewport_size.x:
		root.position.x = viewport_size.x - tooltip_size.x - 20
	if pos.y + tooltip_size.y > viewport_size.y:
		root.position.y = viewport_size.y - tooltip_size.y - 20

func hide_tooltip():
	root.visible = false
