class_name CraftUI
extends CanvasLayer

@onready var panel := $UIRoot/PanelContainer
@onready var list := $UIRoot/PanelContainer/CraftContainer/RecipesContainer/RecipesList
@onready var container := $UIRoot/PanelContainer/CraftContainer/RecipesContainer
@onready var root := $UIRoot

var anim: Tween

func _ready() -> void:
	visible = false
	update_recipes()

func update_recipes():
	container.queue_sort()
	
	for child in list.get_children():
		child.queue_free()

	for recipe in RecipeDB.get_all_recipes():
		var recipe_ui = preload("res://recipes/craft_slot.tscn").instantiate()
		list.add_child(recipe_ui)
		recipe_ui.setup(recipe, craft_recipe) 
		recipe_ui.update()

func craft_recipe(recipe: RecipeRes):
	# Check enough items
	for ing in recipe.ingredients:
		var item_id = ing.item.id
		var item_name = ing.item.name
		var count = ing.count

		if InventoryData.get_item_count(item_id) < count:
			print("Not enough items for craft | name: ", item_name, ", id: ", item_id)
			return

	# Remove ingredients from inventory
	for ing in recipe.ingredients:
		var id = ing.item.id
		var count = ing.count
		InventoryData.remove_item(id, count)
	print("Items were removed from inventory: ", recipe.name)

	InventoryData.add_item(recipe.result, recipe.result_count)
	update_recipes()


# --- Util ---

func toggle(isOn: bool = false):
	if visible and not isOn:
		anim = create_tween()
		anim.tween_property(root, "modulate:a", 0, 0.2).set_ease(Tween.EASE_IN)
		await anim.finished
		visible = isOn || !visible
	else:
		visible = isOn || !visible
		anim = create_tween()
		anim.tween_property(root, "modulate:a", 1, 0.2).set_ease(Tween.EASE_IN)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		toggle()