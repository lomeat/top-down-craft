class_name ConsumeItemRes
extends ItemRes

@export var heal: int
@export var cooldown: float

func get_stats():
	return {
		"Heal": heal,
		"Cooldown": cooldown
	}