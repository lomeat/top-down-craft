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

	player_pickup_area.area_entered.connect(_ready_item)
	player_pickup_area.area_exited.connect(_unready_item)

	GlobalSignals.item_collected.connect(add_to_inventory)
	GlobalSignals.item_ready_pickup.connect(_check_items_collisions)

func _check_items_collisions(item: ItemDrop):
	if player_pickup_area.overlaps_area(item):
		_ready_item(item)

func _ready_item(body: Area2D) -> void:
	if body is ItemDrop:
		if body.can_picked_up:
			pending_pickups.append(body)
			body.run_animation("highlight")

func _unready_item(body: Area2D) -> void:
	if body is ItemDrop and pending_pickups.has(body):
		pending_pickups.erase(body)
		body.run_animation("idle")

func damage_item(target: Node2D, _damage: int):
	if is_instance_valid(target) and target is ItemObject:
		target.take_damage(_damage)

func _physics_process(_delta: float) -> void:
	if player.isAutoloot:
		pickup_items()
	else:
		return


func pickup_items():
	var items = pending_pickups.duplicate()
	pending_pickups.clear()
	
	for item in items:
		if is_instance_valid(item):
			collect_item(item)

func collect_item(item: ItemDrop):
	await item.destroy()
	GlobalSignals.item_collected.emit(item)


func add_to_inventory(item: ItemDrop):
	if not item or not item.item_res:
		push_error("Invalid item in add_to_inventory")

	var id = item.item_res.id
	var item_name = item.item_res.name
	var count = item.count
	
	if inventory.has(item.item_res.id):
		inventory[id].count += count
	else:
		inventory[id] = { "name": item_name, "count": count }
	
	print("To inventory was added: ", item.item_res.name)
	update_inventory_ui()

func update_inventory_ui():
	print("Current inventory:")
	for id in inventory:
		print(" - ", inventory[id].name, ": ", inventory[id].count)
