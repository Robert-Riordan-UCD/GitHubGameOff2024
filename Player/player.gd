class_name Player
extends CharacterBody2D

signal hit

@export_category("Movement")
@export var max_run_speed: float = 300
@export var time_to_max_speed: float = 0.5
@export var time_to_min_speed: float = 0.1

@export_group("Dash")
@export var dash_boost: float = 2
@export var dash_time: float = 0.2

@export_group("Jump")
@export var gravity: float = 1000
@export_range(0, 1) var air_control: float = 0.75
@export var coyote_time: float = 0.2
@export var jump_buffer: float = 0.4
@export var jump_height: float = 4
@export var fall_multiplier: float = 2

@export_group("Wall slide")
@export_range(0, 1) var max_wall_slide_speed: float = 25
@export var wall_jump_out_force: float = 350

# Jump state variables
@onready var coyote_avalible: bool = false
@onready var coyote_was_on_floor: bool = false
@onready var jump_buffer_avalible: bool = false

@onready var dashing: bool = false
@onready var can_dash: bool = false
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@onready var can_move: bool = true

func _physics_process(delta: float) -> void:
	if not can_move:
		update_x_velocity(0, delta)
		apply_gravity(delta)
		move_and_slide()
		return
	
	# Left/right movement
	var direction: float = Input.get_axis("left", "right")
	if not dashing:
		if is_on_floor():
			update_x_velocity(direction, delta)
		elif not is_on_wall():
			update_x_velocity(direction*air_control, delta)
	
	apply_gravity(delta)
	update_jump_buffer()
	update_coyote_timer()
	update_dash_allowed()
	move_and_slide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		jump()
	elif event.is_action_pressed("flip_gravity"):
		up_direction = -up_direction
	elif event.is_action_pressed("dash"):
		dash()


func update_x_velocity(direction: float, delta: float) -> void:
	if direction:
		velocity.x += direction * max_run_speed * delta / time_to_max_speed
		velocity.x = clamp(velocity.x, -max_run_speed, max_run_speed)
	else:
		if velocity.x > 0:
			velocity.x -= max_run_speed * delta / time_to_min_speed
		elif velocity.x < 0:
			velocity.x += max_run_speed * delta / time_to_min_speed


func jump() -> void:
	if is_on_floor() or jump_buffer_avalible or coyote_avalible:
		velocity.y = up_direction.y * jump_height * gravity / 10
	elif is_on_wall_only():
		velocity.y = up_direction.y * jump_height * gravity / 10
		velocity.x = get_wall_normal().x * wall_jump_out_force


func dash() -> void:
	if dashing or not can_dash: return
	var direction: Vector2 = Vector2(Input.get_axis("left", "right"), Input.get_axis("up","down"))
	if direction != Vector2.ZERO:
		velocity = dash_boost*direction*max_run_speed
		dashing = true
		can_dash = false
		collision_shape_2d.disabled = true
		await get_tree().create_timer(dash_time).timeout
		collision_shape_2d.disabled = false
		dashing = false


func apply_gravity(delta: float) -> void:
	if dashing: return
	if is_on_wall():
		if wall_slide(delta):
			return
	if Input.is_action_pressed("jump") and velocity.y*up_direction.y > 0:
		velocity.y -= delta*gravity*up_direction.y
	else:
		velocity.y -= delta*gravity*fall_multiplier*up_direction.y


# Returns true is wall slide is applied. Otherwise false
func wall_slide(delta: float) -> bool:
	# Only slide if falling or player wants to
	if velocity.y*up_direction.y < 0:
		if Input.get_axis("slide_down", "slide_up") == up_direction.y:
			velocity.y -= delta*gravity*up_direction.y
		else:
			velocity.y -= delta*gravity*up_direction.y
			velocity.y = clamp(velocity.y, -max_wall_slide_speed, max_wall_slide_speed)
		return true
	return false

func update_jump_buffer() -> void:
	if not is_on_floor() and Input.is_action_just_pressed("jump"):
		jump_buffer_avalible = true
		await get_tree().create_timer(jump_buffer).timeout
		jump_buffer_avalible = false


func update_coyote_timer() -> void:
	if coyote_was_on_floor and not is_on_floor():
		coyote_avalible = true
		await get_tree().create_timer(coyote_time).timeout
		coyote_avalible = false
	coyote_was_on_floor = is_on_floor()


func update_dash_allowed() -> void:
	if is_on_floor():
		can_dash = true


func lock_control():
	can_move = false


func unlock_control():
	can_move = true


func _on_hurt_box_body_entered(_body: Node2D) -> void:
	hit.emit()
