extends CharacterBody2D

@export_category("On Ground")
@export var max_run_speed: float = 300
@export var time_to_max_speed: float = 0.75
@export var time_to_min_speed: float = 0.25

@export_category("In Air")
@export var gravity: float = 20
@export_range(0, 1) var air_control: float = 0.75

func _physics_process(delta: float) -> void:
	# Left/right movement
	var direction: float = Input.get_axis("left", "right")
	if is_on_floor():
		update_x_velocity(direction, delta)
	else:
		update_x_velocity(direction*air_control, delta)
	
	apply_gravity(delta)
	move_and_slide()


func update_x_velocity(direction: float, delta: float) -> void:
	if direction:
		velocity.x += direction * max_run_speed * delta / time_to_max_speed
		velocity.x = clamp(velocity.x, -max_run_speed, max_run_speed)
	else:
		if velocity.x > 0:
			velocity.x -= max_run_speed * delta / time_to_min_speed
		elif velocity.x < 0:
			velocity.x += max_run_speed * delta / time_to_min_speed


func apply_gravity(delta: float) -> void:
	velocity.y += delta*gravity
