class_name Player
extends CharacterBody2D

@onready var sprite := $Sprite2D
@onready var sword_area := $Sword/Sprite2D/Area2D
@onready var sword_anim := $Sword/AnimationPlayer

signal sword_attacked(target: Node2D, _damage: int)
signal pickup_requested()

@export var speed := 1000
@export var acceleration := 40
@export var friction := 100
@export var damage := 1

# Movement
var direction := Vector2.ZERO
var current_velocity := Vector2.ZERO

# Attack
var is_attacking := false
var attack_cooldown := 0.3
var cooldown_timer := 0.0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		pickup_requested.emit()

func _physics_process(delta: float) -> void:
	get_direction()
	handle_rotation()
	perform_movement(delta)
	attack(delta)
	# --- Godot Experience ---
	move_and_slide()

func get_direction() -> void:
	direction = Vector2.ZERO
	
	direction.x = Input.get_axis("left", "right")
	direction.y = Input.get_axis("up", "down")

	if direction.length() > 0:
		direction = direction.normalized()

func perform_movement(delta: float) -> void:
	var target_velocity := direction * speed

	if direction != Vector2.ZERO:
		current_velocity = current_velocity.lerp(target_velocity, acceleration * delta)
	else:
		current_velocity = current_velocity.lerp(Vector2.ZERO, friction * delta)

	velocity = current_velocity

func handle_rotation():
	var mouse_position = get_global_mouse_position()
	sprite.global_rotation = (mouse_position - global_position).angle()

	if not sword_anim.is_playing():
		$Sword.global_rotation = (mouse_position - global_position).angle()


func attack(delta: float) -> void:
	if cooldown_timer > 0:
		cooldown_timer -= delta
	
	if Input.is_action_just_pressed("attack") and cooldown_timer <= 0:
		# start
		is_attacking = true
		cooldown_timer = attack_cooldown
		sword_area.monitoring = true
		sword_anim.play("swing_attack")
		# stop
		await sword_anim.animation_finished
		sword_area.monitoring = false
		is_attacking = false
		

func _on_sword_area_body_entered(body: Node2D) -> void:
	if is_attacking:
		sword_attacked.emit(body, damage)



