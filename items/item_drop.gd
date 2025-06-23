class_name ItemDrop
extends Area2D

@onready var sprite: Sprite2D = $Sprite2D

@export var animation_duration := 0.4

func setup(res: ItemCraftResource):
	if not res or not res.texture:
		push_error("ItemResource is null!")
		return

	if not sprite:
		push_error("Ther is no sprite instance")
		var new_sprite = Sprite2D.new()
		new_sprite.texture = res.texture
		new_sprite.position = Vector2.ZERO
		add_child(new_sprite)
	else:
		sprite.texture = res.texture
	
	if has_node("Shadow"):
		$Shadow.texture = res.texture
		$Shadow.modulate = Color(0, 0, 0, 0.3)

	
func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	GlobalSignals.item_ready_pickup.emit(self)

	
func destroy():
	collect_animation(animation_duration)
	await get_tree().create_timer(animation_duration).timeout
	queue_free()


func collect_animation(duration: float) -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", get_tree().get_first_node_in_group("player").global_position, duration)
	tween.tween_property(self, "scale", Vector2(1, 1), duration)
	tween.tween_property(self, "modulate:a", 0.0, duration)
