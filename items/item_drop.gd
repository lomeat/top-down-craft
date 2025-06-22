class_name ItemCraft
extends Area2D

signal can_picked_up()

# var is_can_picked_up := false

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	can_picked_up.emit()
	# is_can_picked_up = true

# func _on_body_entered(_body: Node2D) -> void:
# 	var bodies = get_overlapping_bodies()

# 	for body in bodies:
# 		if is_can_picked_up and body is Player:
# 			can_picked_up.emit(body)

func destroy() -> void:
	queue_free()
	# TODO: Animation also