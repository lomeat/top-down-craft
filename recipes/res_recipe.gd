class_name RecipeRes
extends Resource

@export var id: String = ""
@export var name: String = ""
@export var result: ItemRes
@export var result_count: int = 1

@export var ingredients: Array[RecipeIngredientRes] = []

