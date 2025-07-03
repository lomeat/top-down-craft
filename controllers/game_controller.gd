extends Node2D

@onready var player: Player = $Player
@onready var player_pickup_area: Area2D = $Player/PickupArea

var pending_pickups = []

func _ready() -> void:
	if not player:
		push_error("Add a Player to the scene!")

	var player_inventory = InventoryData.new()
	player_inventory.inv_size = 8
	InventoryManager.register_inventory("player", player_inventory)
	
	player.sword_attacked.connect(damage_item)
	player.pickup_requested.connect(pickup_items)

	player_pickup_area.area_entered.connect(_ready_item)
	player_pickup_area.area_exited.connect(_unready_item)

	await get_tree().create_timer(0.1).timeout
	_check_items_collisions()


func _check_items_collisions():
	var areas = player_pickup_area.get_overlapping_areas()
	for area in areas:
		if area is Item:
			_ready_item(area)

func _ready_item(body: Area2D) -> void:
	if body is Item:
		if body.can_picked_up:
			_pick_up(body)
		else:
			body.ready_for_pickup.connect(_on_item_ready.bind(body), CONNECT_ONE_SHOT)

func _on_item_ready(item: Item):
	if player_pickup_area.overlaps_area(item) and item.can_picked_up:
		_pick_up(item)

func _pick_up(item: Item):
	if not pending_pickups.has(item):
		pending_pickups.append(item)
		item.run_animation("highlight")

func _unready_item(body: Area2D) -> void:
	if body is Item and pending_pickups.has(body):
		pending_pickups.erase(body)
		body.run_animation("idle")

func damage_item(target: Node2D, _damage: int):
	if is_instance_valid(target) and target is ItemObject:
		target.take_damage(_damage)

func _physics_process(_delta: float) -> void:
	if player.isAutoloot:
		pickup_items()

func pickup_items():
	var items = pending_pickups.duplicate()
	pending_pickups.clear()
	
	for item in items:
		if is_instance_valid(item):
			collect_item(item)

func collect_item(item: Item):
	await item.destroy()

	var player_inv = InventoryManager.get_inv("player")
	if player_inv:
		player_inv.add_item(item.item_res, 1)
	else:
		push_error("Player inventory not found")


