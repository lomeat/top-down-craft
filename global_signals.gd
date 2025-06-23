extends Node

signal item_ready_pickup(item: ItemDrop)
signal item_collected(item: ItemDrop)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

# Never be called
func remove_vscode_warnings():
	item_ready_pickup.emit()
	item_collected.emit()