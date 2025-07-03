class_name RecipeItemUI
extends Control

@onready var result_icon := $RecipeContainer/ResultIcon
@onready var result_name := $RecipeContainer/ResultName
@onready var ingredients_container := $RecipeContainer/IngredientsContainer
@onready var craft_button := $RecipeContainer/CraftButton

@export var inventory_id: String = "player"

var recipe: RecipeRes
var callback: Callable


func _ready() -> void:
	InventoryManager.inventory_updated.connect(func(_a): update())

func setup(new_recipe: RecipeRes, new_callback: Callable):
	recipe = new_recipe
	callback = new_callback

	result_icon.texture = recipe.result.texture
	result_name.text = recipe.result.name

	for child in ingredients_container.get_children():
		child.queue_free()

	for ing in recipe.ingredients:
		var item_res = ing["item"]
		var count = ing["count"]

		var container = HBoxContainer.new()
		container.add_theme_constant_override("separation", 4)
		var icon = TextureRect.new()
		icon.texture = item_res.texture
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = Vector2(48, 48)

		var label = Label.new()
		var l_settings = LabelSettings.new()
		label.label_settings = l_settings
		label.label_settings.font_size = 24
		label.text = "x" + str(count)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		
		container.add_child(label)
		container.add_child(icon)
		ingredients_container.add_child(container)
	
	craft_button.pressed.connect(_on_craft_pressed)

func _on_craft_pressed():
	callback.call(recipe)

func update() -> void:
	var inv = InventoryManager.get_inv(inventory_id)
	if not inv:
		return
	
	var can_craft = true

	for ing in recipe.ingredients:
		var item_id = ing.item.id
		var required_count = ing.count
		var has_count = inv.get_item_count(item_id)

		if has_count == null or has_count < required_count:
			can_craft = false
			break

	craft_button.disabled = !can_craft

	
