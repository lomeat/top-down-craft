extends Node

signal item_ready_pickup(item: Item)
signal item_collected(item: Item)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

# Never be called
func remove_vscode_warnings():
	item_ready_pickup.emit()
	item_collected.emit()

# --- Scene actions ---

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("restart")):
		get_tree().reload_current_scene()
		InventoryManager.clear()
	if (event.is_action_pressed("ui_cancel")):
		get_tree().quit()