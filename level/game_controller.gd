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

	GlobalSignals.item_collected.connect(InventoryData.add_item)
	GlobalSignals.item_ready_pickup.connect(_check_items_collisions)

func _check_items_collisions(item: Item):
	if player_pickup_area.overlaps_area(item):
		_ready_item(item)

func _ready_item(body: Area2D) -> void:
	if body is Item:
		if body.can_picked_up:
			pending_pickups.append(body)
			body.run_animation("highlight")

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
	else:
		return


func pickup_items():
	var items = pending_pickups.duplicate()
	pending_pickups.clear()
	
	for item in items:
		if is_instance_valid(item):
			collect_item(item)

func collect_item(item: Item):
	await item.destroy()
	GlobalSignals.item_collected.emit(item.item_res, 1)




