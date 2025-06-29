class_name InventorySlotUI
extends Control

@onready var item_icon := $ItemIcon
@onready var count_label := $CountLabel
@onready var back_icon := $BackIcon

@onready var tooltip: ItemTooltip = preload("res://items/item_tooltip.tscn").instantiate()
@export var tooltip_delay = 0.3

var tooltip_timer: Timer
var is_mouse_over: bool = false

var anim: Tween
var item_id: String
var item_res: ItemRes

func _ready() -> void:
	back_icon.modulate.a = 0

	tooltip_timer = Timer.new()
	tooltip_timer.wait_time = tooltip_delay
	tooltip_timer.one_shot = true
	add_child(tooltip_timer)
	tooltip_timer.timeout.connect(_show_tooltip)

	tooltip = preload("res://items/item_tooltip.tscn").instantiate()
	add_child(tooltip)
	tooltip.root.visible = false

	mouse_entered.connect(_start_timer)
	mouse_exited.connect(_stop_timer)

# --- Main (slot) ---

func update_slot(id: String, count: int) -> void:
	if not id or id.is_empty() or count <= 0:
		clear_slot()
		return 
	
	var res = ItemDB.get_item(id)
	if res:
		item_icon.texture = res.texture
		count_label.text = str(count) if count > 1 else ""

	item_id = id	
	item_res = res
	animate()

func clear_slot():
	item_icon.texture = null
	count_label.text = ""

# --- Tooltip ---

func _start_timer(): 
	if not item_id.is_empty():
		is_mouse_over = true
		tooltip_timer.start()

func _stop_timer():
	is_mouse_over = false
	tooltip_timer.stop()
	tooltip.hide_tooltip()

func _tooltip_update_position():
	tooltip.show_at_position(get_global_mouse_position() + Vector2(20, 20))

func _show_tooltip():
	if is_mouse_over and item_res:
		tooltip.setup(item_res)
		_tooltip_update_position()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and tooltip.root.visible:
		_tooltip_update_position()

# --- Animation ---

func animate():
	item_icon.scale = Vector2(0.6, 0.6)
	anim = create_tween()
	anim.tween_property(item_icon, "scale", Vector2(1.1, 1.1), 0.1).set_ease(Tween.EASE_IN)
	anim.tween_property(back_icon, "modulate:a", 0.3, 0.1).set_ease(Tween.EASE_IN)
	anim.tween_property(item_icon, "scale", Vector2.ONE, 0.1).set_ease(Tween.EASE_IN)
