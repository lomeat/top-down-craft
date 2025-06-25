class_name ItemObject
extends StaticBody2D

@onready var sprite := $Sprite2D

@export var loot_table: LootTable
@export var max_health := 2

var current_health = max_health
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()

func take_damage(damage: int) -> void:
	sprite.modulate = Color.DIM_GRAY
	await get_tree().create_timer(0.1).timeout

	if current_health > 0:
		current_health -= damage

	if current_health <= 0:
		destroy()

	sprite.modulate = Color.WHITE
	

func destroy() -> void:
	drop_loot()
	queue_free()

func drop_loot():
	if not loot_table:
		print("Determine loot table for ", self.name)
		return
	
	for entry in loot_table.entries:
		if rng.randf_range(0, 100) <= entry.drop_chance:
			var drop_count = rng.randi_range(entry.min_amount, entry.max_amount)
			for i in range(drop_count):
				spawn_item(entry.item, drop_count)
			

func spawn_item(item_res: ItemResource, total: int):
	var item = preload("res://items/item_drop.tscn").instantiate()
	var spread_radius := 128.0
	var rand_int = randf_range(1, total)
	var angle := rng.randf_range(1, TAU)
	var offset := Vector2(
		cos(angle) * spread_radius / 2 * sqrt(float(rand_int) / total), 
		sin(angle) * spread_radius * sqrt(float(rand_int) / total)
	)

	item.setup(item_res, 1)
	item.global_position = global_position
	var target_position = global_position + offset
	
	var parent = get_parent()
	if parent:
		parent.add_child(item)
		await get_tree().process_frame
		spawn_animation(item, target_position)
	else:
		printerr("There is no parent to spawn dropped item")

func spawn_animation(item: Node2D, target_position: Vector2):
	var tween = item.create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)

	tween.tween_property(item, "global_position", target_position, 0.4)

	if item.has_node("Sprite2D"):
		var main_sprite = item.get_node("Sprite2D")
		main_sprite.modulate.a = 0.5
		tween.tween_property(main_sprite, "modulate:a", 1.0, 0.4)

	if item.has_node("Shadow"):
		var shadow = item.get_node("Shadow")
		var original_a = shadow.modulate.a
		shadow.modulate.a = 0.0
		tween.tween_property(shadow, "modulate:a", original_a, 0.3)
