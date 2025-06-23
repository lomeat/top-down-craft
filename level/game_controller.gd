extends Node2D

@onready var player: Player = $Player
@onready var player_pickup_area: Area2D = $Player/PickupArea

var inventory = {}
var pending_pickups = []

func _ready() -> void:
	if not player:
		push_error("Add a Player to the scene!")
	
	player.sword_attacked.connect(damage_item)
	player.pickup_requested.connect(pickup_items)

	player_pickup_area.body_entered.connect(_ready_items)
	player_pickup_area.body_exited.connect(_unready_items)

	# GlobalSignals.item_ready_pickup.connect(_on_item_available)
	GlobalSignals.item_collected.connect(add_to_inventory)

func _ready_items(body: Node2D) -> void:
	print("body entered")
	if body is ItemDrop:
		print("body is ItemDrop")
		if body.can_picked_up:
			print("body can picked up")
			pending_pickups.append(body)
			body.run_animation("highlight")

func _unready_items(body: Node2D) -> void:
	if body is ItemDrop and pending_pickups.has(body):
		pending_pickups.erase(body)
		body.run_animation("idle")
	

func damage_item(target: Node2D, _damage: int):
	if is_instance_valid(target) and target is ItemObject:
		target.take_damage(_damage)

func highlight_item(item: ItemDrop):
	var tween = item.create_tween()
	tween.set_loops()
	tween.tween_property(item, "scale", Vector2(1.1, 1.1), 0.5)
	tween.tween_property(item, "scale", Vector2(1.0, 1.0), 0.5)

# func _on_item_available(item: ItemDrop):
# 	pending_pickups.append(item)
# 	highlight_item(item)

func pickup_items():
	for item in pending_pickups:
		if is_instance_valid(item):
			collect_item(item)
			pending_pickups.erase(item)
	# pending_pickups.clear()

func collect_item(item: ItemDrop):
	await item.run_animation("idle")
	await item.destroy()
	GlobalSignals.item_collected.emit(item)


func add_to_inventory(item: ItemDrop):
	if inventory.has(item.item_res.id):
		inventory[item.item_res.id] += item.count
	else:
		inventory[item.item_res.id] = item.count
	
	print("To inventory was added: ", item.item_res.name)
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
