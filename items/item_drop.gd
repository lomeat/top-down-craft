class_name ItemDrop
extends Area2D

@onready var sprite: Sprite2D = $Sprite2D

@export var animation_duration := 0.4

var item_res: ItemCraftResource
var count: int = 1
var animation: Tween = create_tween()
var can_picked_up := false

func setup(res: ItemCraftResource, total: int):
	if not res or not res.texture:
		push_error("ItemResource is null!")
		return

	if not sprite:
		# push_error("There is somehow no sprite instance")
		var new_sprite = Sprite2D.new()
		new_sprite.texture = res.texture
		new_sprite.position = Vector2.ZERO
		add_child(new_sprite)
		sprite = new_sprite
	else:
		sprite.texture = res.texture

	item_res = res
	count = total
	
	if has_node("Shadow"):
		var shadow = $Shadow
		shadow.texture = res.texture
		shadow.modulate = Color(0, 0, 0, 0.3)


func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	can_picked_up = true
	GlobalSignals.item_ready_pickup.emit(self)
	
func destroy():
	await run_animation("collect")
	queue_free()

func run_animation(state_anim := "idle"):
	if not can_picked_up:
		return

	match state_anim:
		"idle":
			animate_idle()
		"highlight":
			animate_ready_pick_up()
		"collect":
			animate_collect(animation_duration)
		_:
			animate_idle()
	await animation.finished


func animate_ready_pick_up():
	animation.kill()
	animation = create_tween()
	animation.set_loops(0)
	animation.tween_property(self, "scale", Vector2(1.2, 1.2), 0.5)
	animation.tween_property(self, "scale", Vector2(1.0, 1.0), 0.5)

func animate_idle():
	animation.kill()
	animation = create_tween()
	animation.tween_property(self, "scale", Vector2.ONE, 0.1)

func animate_collect(duration: float) -> void:
	var player_pos = get_tree().get_first_node_in_group("player").global_position
	animation.kill()
	animation = create_tween()
	animation.set_parallel(true)
	animation.tween_property(self, "global_position", player_pos, duration)
	animation.tween_property(self, "scale", Vector2(1, 1), duration)
	animation.tween_property(self, "modulate:a", 0.0, duration)

