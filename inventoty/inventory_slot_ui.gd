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

var slot_id: int = -1
var inventory_id: String = ""

var animation: Tween

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_STOP
	back_icon.modulate.a = 0

	tooltip_timer = Timer.new()
	tooltip_timer.wait_time = tooltip_delay
	tooltip_timer.one_shot = true
	add_child(tooltip_timer)
	tooltip_timer.timeout.connect(_show_tooltip)

	add_child(tooltip)
	tooltip.root.visible = false

	var outline_material = ShaderMaterial.new()
	outline_material.shader = load("res://items/outline.gdshader")
	outline_material.set_shader_parameter("outline_width", 0.0)
	outline_material.set_shader_parameter("outline_color", Color(1,1,1,0))
	item_icon.material = outline_material

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

# --- Other ---

func _on_mouse_entered() -> void:
	_start_timer()
	_start_hover_animation()
	_set_current()

func _on_mouse_exited() -> void:
	_stop_timer()
	_stop_hover_animation()
	_reset_current()


# --- Main (slot) ---

# Dictionary | null
func update_slot(slot) -> void:
	if not slot:
		clear_slot()
		return

	item_icon.texture = slot.data.texture
	count_label.text = str(slot.count) if slot.count > 1 else ""

	item_res = slot.data
	item_id = slot.data.id
	_update_animation()

func clear_slot():
	item_icon.texture = null
	count_label.text = ""
	back_icon.modulate.a = 0
	item_res = null
	item_id = ""

# --- Dragging ---

func _set_current():
	InventoryManager.current_inventory_id = inventory_id
	InventoryManager.current_slot = self

func _reset_current():
	if InventoryManager.current_slot == self:
		InventoryManager.current_inventory_id = ""
		InventoryManager.current_slot = null

func _gui_input(event: InputEvent) -> void:
	# Start dragging
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT and not InventoryManager.drag_state:
			var inventory = InventoryManager.get_inv(inventory_id)
			if inventory and inventory.get_slot(slot_id):
				InventoryManager.start_drag(inventory_id, slot_id)
				clear_slot()
				get_viewport().set_input_as_handled()
	# Tooltip
	if event is InputEventMouseMotion and tooltip.root.visible:
		_tooltip_update_position()


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


# --- Animation ---

func _update_animation():
	item_icon.scale = Vector2(0.6, 0.6)
	anim = create_tween()
	anim.tween_property(item_icon, "scale", Vector2(1.1, 1.1), 0.1).set_ease(Tween.EASE_IN)
	anim.tween_property(back_icon, "modulate:a", 0.3, 0.1).set_ease(Tween.EASE_IN)
	anim.tween_property(item_icon, "scale", Vector2.ONE, 0.1).set_ease(Tween.EASE_IN)

func _start_hover_animation():
	if is_mouse_over and item_res:
		item_icon.scale = Vector2.ONE
		animation = create_tween()
		animation.set_parallel(true) 
		animation.tween_property(item_icon.material, "shader_parameter/outline_width", 4.0, 0.1).set_ease(Tween.EASE_IN)
		animation.tween_property(item_icon.material, "shader_parameter/outline_color", Color(1, 1, 1, 0.5), 0.1).set_ease(Tween.EASE_IN)
		animation.tween_property(item_icon, "scale", Vector2(1.2, 1.2), 0.1).set_ease(Tween.EASE_IN)

func _stop_hover_animation():
	if not item_res:
		return
	
	if not is_mouse_over:
		animation = create_tween()
		animation.set_parallel(true) 
		animation.tween_property(item_icon.material, "shader_parameter/outline_width", 0, 0.1).set_ease(Tween.EASE_IN)
		animation.tween_property(item_icon.material, "shader_parameter/outline_color", Color(1, 1, 1, 0), 0.1).set_ease(Tween.EASE_IN)
		animation.tween_property(item_icon, "scale", Vector2.ONE, 0.1).set_ease(Tween.EASE_IN)