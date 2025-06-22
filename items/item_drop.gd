class_name ItemDrop
extends Area2D

signal was_collected

var is_can_picked_up := false

func _ready() -> void:
	await get_tree().create_timer(0.3).timeout
	is_can_picked_up = true


func _on_body_entered(_body: Node2D) -> void:
	var bodies = get_overlapping_bodies()

	for body in bodies:
		if is_can_picked_up and body is Player:
			was_collected.emit()
			queue_free()