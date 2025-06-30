class_name SeedItemRes
extends ItemRes

@export var plant_id: String
@export var grow_time: float

func get_stats():
	return {
		"Grow time": grow_time
	}