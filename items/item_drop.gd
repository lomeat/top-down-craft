class_name ItemDrop
extends Area2D

@onready var sprite: Sprite2D = $Sprite2D

@export var animation_duration := 0.4

var item_res: ItemCraftResource
var count: int = 1
var can_picked_up := false

func setup(res: ItemCraftResource, total: int):
	if not res or not res.texture:
		push_error("ItemResource is null!")
		return

	if not sprite:
		push_error("There is somehow no sprite instance")
		var new_sprite = Sprite2D.new()
		new_sprite.texture = res.texture
		new_sprite.position = Vector2.ZERO
		add_child(new_sprite)
	else:
		sprite.texture = res.texture

	item_res = res
	count = total
	
	if has_node("Shadow"):
		$Shadow.texture = res.texture
		$Shadow.modulate = Color(0, 0, 0, 0.3)


	
func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	can_picked_up = true

	
func destroy():
	await collect_animation(animation_duration)
	queue_free()


func collect_animation(duration: float) -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", get_tree().get_first_node_in_group("player").global_position, duration)
	tween.tween_property(self, "scale", Vector2(1, 1), duration)
	tween.tween_property(self, "modulate:a", 0.0, duration)
	await tween.finished

func _on_body_was_entered(body: Node2D) -> void:
	if can_picked_up and body is Player:
		GlobalSignals.item_ready_pickup.emit(self)
