extends Node

var items: Dictionary = {}

func _ready():
	load_items("res://items/crafts/")

func load_items(path: String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file = dir.get_next()
		while file != "":
			if file.ends_with(".tres"):
				var item: ItemResource = load(path + file)
				if item:
					items[item.id] = item
			file = dir.get_next()

func get_items() -> Dictionary:
	return items

func get_item(id: String) -> ItemResource:
	return items[id]
