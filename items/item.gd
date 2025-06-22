class_name ItemObject
extends StaticBody2D

@onready var sprite := $Sprite2D

@export_category("Loot Settings")
@export var loot_item: PackedScene
@export_range(0, 100, 1, "suffix:%") var drop_percent := 75
@export var min_amount := 1
@export var max_amount := 3
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
	drop_item()
	queue_free()

func drop_item():
	if not loot_item:
		return

	if rng.randf_range(0, 100) > drop_percent:
		return

	var drop_count = rng.randi_range(min_amount, max_amount)
	for i in range(drop_count):
		spawn_item_in_random_pos(i, drop_count)


func spawn_item_in_random_pos(index: int, total: int):
	var item = loot_item.instantiate()
	var spread_radius := 264.0
	var angle := rng.randf_range(0, TAU)
	var offset := Vector2(
		cos(angle) * spread_radius / 2 * sqrt(float(index) / total), 
		sin(angle) * spread_radius * sqrt(float(index) / total)
	)
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

	tween.tween_property(item, "global_position", target_position, 0.5)
	item.modulate.a = 0.5
	tween.tween_property(item, "modulate:a", 1, 0.3)

	if item.has_node("Shadow"):
		var shadow = item.get_node("Shadow")
		var original_a = shadow.modulate.a
		shadow.modulate.a = 0.0
		tween.tween_property(shadow, "modulate:a", original_a, 0.6)
