class_name ItemRes
extends Resource

@export_category("Main")
@export var id: String = ""
@export var name: String = ""
@export var texture: Texture2D
@export_enum("material", "tool", "consume", "seed") var category: String = ""
@export_enum("placeable", "undestructable") var tags: Array[String] = []
@export_category("Optional")
@export_multiline var desc: String = ""

# Make inventory can keep some items with same id
# @export var max_stack: int = 99