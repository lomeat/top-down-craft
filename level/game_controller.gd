extends Node2D

@onready var player: Player = $Player

var inventory = {}
var pending_pickups = []

func _ready() -> void:
	player.sword_attacked.connect(damage_item)
	player.pickup_requested.connect(_on_pickup_requested)
	GlobalSignals.item_ready_pickup.connect(_on_item_available)
	GlobalSignals.item_collected.connect(_on_item_collected)

func damage_item(target: Node2D, _damage: int):
	if is_instance_valid(target) and target is ItemObject:
		target.take_damage(_damage)

# TODO: Make highlight white border with sprite
func highlight_item(item: ItemDrop):
	var tween = item.create_tween()
	tween.set_loops()
	tween.tween_property(item, "scale", Vector2(1.1, 1.1), 0.5)
	tween.tween_property(item, "scale", Vector2(1.0, 1.0), 0.5)

func _on_item_available(item: ItemDrop):
	pending_pickups.append(item)
	highlight_item(item)


func _on_pickup_requested():
	for item in pending_pickups:
		if is_instance_valid(item):
			collect_item(item)
	pending_pickups.clear()

func collect_item(item: ItemDrop):
	var tween = item.create_tween()
	tween.tween_property(item, "scale", Vector2(1.0, 1.0), 0.1)
	await item.destroy()
	GlobalSignals.item_collected.emit(item)

func _on_item_collected(item: ItemDrop):
	if inventory.has(item.item_res.id):
		inventory[item.item_res.id] += item.count
	else:
		inventory[item.item_res.id] = item.count
	
	print("Inventory updated: ", inventory)
	
	update_inventory_ui()

func update_inventory_ui():
	print("Current inventory:")
	for item in inventory:
		print(" - ", item, ": ", inventory[item])

# --- Scene actions ---

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("restart")):
		get_tree().reload_current_scene()
	if (event.is_action_pressed("ui_cancel")):
		get_tree().quit()
