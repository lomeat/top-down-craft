class_name LootTableEntry
extends Resource

@export var item: ItemResource
@export_range(0, 100) var drop_chance: int = 100
@export var min_amount: int = 1
@export var max_amount: int = 1