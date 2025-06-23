extends Node2D

@onready var player: Player = $Player

var inventory = []

func _ready() -> void:
	player.sword_attacked.connect(damage_item)

func damage_item(target: Node2D, _damage: int):
	if is_instance_valid(target) and target is ItemObject:
		target.take_damage(_damage)

# --- Scene actions ---

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("restart")):
		get_tree().reload_current_scene()
	if (event.is_action_pressed("ui_cancel")):
		get_tree().quit()