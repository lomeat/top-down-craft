extends Node

var recipes: Dictionary = {}

func _ready():
	load_recipes()

func load_recipes():
	var dir = DirAccess.open("res://recipes/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var recipe = load("res://recipes/" + file_name)
				recipes[recipe.id] = recipe
			file_name = dir.get_next()

func get_recipe(id: String) -> RecipeRes:
	return recipes.get(id)

func get_recipes() -> Dictionary:
	return recipes

func get_all_recipes() -> Array:
	return recipes.values()
