extends CharacterBody2D

@export_category("On Ground")
@export var max_run_speed: float = 300
@export var time_to_max_speed: float = 0.75
@export var time_to_min_speed: float = 0.25

@export_category("In Air")
@export var gravity: float = 1000
@export_range(0, 1) var air_control: float = 0.75
@export var coyote_time: float = 0.2
@export var jump_buffer: float = 0.4
@export var jump_height: float = 4

# Jump state variables
@onready var coyote_avalible: bool = false
@onready var coyote_was_on_floor: bool = false
@onready var jump_buffer_avalible: bool = false

func _physics_process(delta: float) -> void:
	# Left/right movement
	var direction: float = Input.get_axis("left", "right")
	if is_on_floor():
		update_x_velocity(direction, delta)
	else:
		update_x_velocity(direction*air_control, delta)
	
	apply_gravity(delta)
	update_jump_buffer()
	update_coyote_timer()
	move_and_slide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		jump()


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
		velocity.y = -jump_height * gravity / 10


# FIXME: make a better gravity function
func apply_gravity(delta: float) -> void:
	velocity.y += delta*gravity


func update_jump_buffer() -> void:
	if not is_on_floor() and Input.is_action_just_pressed("jump"):
		print("Jump buffer avalible")
		jump_buffer_avalible = true
		await get_tree().create_timer(jump_buffer).timeout
		jump_buffer_avalible = false
		print("Jump NOT buffer avalible")


func update_coyote_timer() -> void:
	if coyote_was_on_floor and not is_on_floor():
		coyote_avalible = true
		await get_tree().create_timer(coyote_time).timeout
		coyote_avalible = false
	coyote_was_on_floor = is_on_floor()
