class_name ToolItemRes
extends ItemRes

@export var damage: int
@export var durability: int

func get_stats():
	return {
		"Damage": damage,
		"Durability": durability
	}