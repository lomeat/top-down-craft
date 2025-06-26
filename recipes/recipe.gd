class_name RecipeRes
extends Resource

@export var id: String = ""
@export var name: String = ""
@export var result: ItemResource
@export var result_count: int = 1
@export_multiline var desc: String = ""

@export var ingredients: Array[RecipeIngredientRes] = []

