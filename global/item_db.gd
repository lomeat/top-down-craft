extends Node

var items: Dictionary = {}

func _ready():
	load_items(["res://items/materials/", "res://items/tools/", "res://items/seeds/", "res://items/consumes/"])

func load_items(paths: Array[String]):
	for path in paths:
		var dir = DirAccess.open(path)
		if dir:
			dir.list_dir_begin()
			var file = dir.get_next()
			while file != "":
				if file.ends_with(".tres"):
					var item: ItemRes = load(path + file)
					if item:
						items[item.id] = item
				file = dir.get_next()

func get_items() -> Dictionary:
	return items

func get_item(id: String) -> ItemRes:
	return items[id]
