class_name ItemRes
extends Resource

@export var id: String = ""
@export var name: String = ""
@export var texture: Texture2D
@export_enum("material", "tool", "consume", "seed") var category: String = ""
@export_enum("placeable", "undestructable") var tags: Array[String] = []
@export_multiline var desc: String = ""