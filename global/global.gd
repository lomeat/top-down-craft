extends Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

# --- Scene actions ---

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("restart")):
		get_tree().reload_current_scene()
		InventoryManager.clear()
	if (event.is_action_pressed("ui_cancel")):
		get_tree().quit()