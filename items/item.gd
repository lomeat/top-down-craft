class_name Item
extends Area2D

@onready var sprite: Sprite2D = $Sprite2D

@export var animation_duration := 0.4

var item_res: ItemRes
var count: int = 1
var animation: Tween = create_tween()
var can_picked_up := false
var back_sprite: Sprite2D
var new_sprite: Sprite2D

func setup(res: ItemRes, total: int):
	if not res or not res.texture:
		push_error("ItemRes is null!")
		return

	if not sprite:
		new_sprite = Sprite2D.new()
		new_sprite.texture = res.texture
		new_sprite.position = Vector2.ZERO
		add_child(new_sprite)
	else:
		sprite.texture = res.texture

	item_res = res
	count = total

	var shadow = $Shadow
	shadow.texture = res.texture
	shadow.modulate = Color(0, 0, 0, 0.3)


func _ready() -> void:
	var outline_material = ShaderMaterial.new()
	outline_material.shader = load("res://items/outline.gdshader")
	outline_material.set_shader_parameter("outline_width", 0.0)
	outline_material.set_shader_parameter("outline_color", Color(1,1,1,0))
	new_sprite.material = outline_material
	
	await get_tree().create_timer(0.3).timeout
	can_picked_up = true
	GlobalSignals.item_ready_pickup.emit(self)

	
func destroy():
	await run_animation("collect")
	queue_free()

func run_animation(state_anim := "idle"):
	if not can_picked_up:
		return

	animation.stop()

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
	animation = create_tween()
	animation.set_parallel(true) 
	animation.tween_property(new_sprite.material, "shader_parameter/outline_width", 4.0, 0.2).set_ease(Tween.EASE_IN)
	animation.tween_property(new_sprite.material, "shader_parameter/outline_color", Color(1, 1, 1, 0.5), 0.2).set_ease(Tween.EASE_IN)
	
func animate_idle():
	animation = create_tween()
	animation.set_parallel(true) 
	animation.tween_property(new_sprite.material, "shader_parameter/outline_width", 0, 0.2).set_ease(Tween.EASE_IN)
	animation.tween_property(new_sprite.material, "shader_parameter/outline_color", Color(1, 1, 1, 0), 0.2).set_ease(Tween.EASE_IN)

func animate_collect(duration: float) -> void:
	var player_pos = get_tree().get_first_node_in_group("player").global_position
	animation = create_tween()
	animation.set_parallel(true)
	animation.tween_property(self, "global_position", player_pos, duration)
	animation.tween_property(self, "scale", Vector2(1, 1), duration)
	animation.tween_property(self, "modulate:a", 0.0, duration)


