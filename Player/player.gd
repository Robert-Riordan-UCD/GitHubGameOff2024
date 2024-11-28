class_name Player
extends CharacterBody2D

signal hit

@export_category("Movement")
@export var max_run_speed: float = 300
@export var time_to_max_speed: float = 0.2
@export var time_to_min_speed: float = 0.02

@export_group("Dash")
@export var dash_boost: float = 2
@export var dash_time: float = 0.2
@export var can_dash_through_wall: bool = true

@export_group("Jump")
@export var gravity: float = 1000
@export_range(0, 1) var air_control: float = 1.0
@export var coyote_time: float = 0.4
@export var jump_buffer: float = 0.4
@export var jump_height: float = 4.5
@export var fall_multiplier: float = 2

@export_group("Wall slide")
@export_range(0, 1) var max_wall_slide_speed: float = 25
@export var wall_jump_out_force: float = 250

@export_group("Inverting")
@export var flip_double_click_timer: float = 0.3

# Jump buffers and coyote timers
@onready var jump_buffer_avalible: bool = false
@onready var coyote_avalible: bool = false
@onready var coyote_was_on_floor: bool = false

@onready var wall_jump_buffer_avalible: bool = false
@onready var wall_coyote_avalible: bool = false
@onready var coyote_was_on_wall: bool = false

@onready var flip_buffer: int = 0
@onready var flip_coyote_avalible: bool = 0
@onready var flip_coyote_was_on_surface: bool = false

# Player state
@onready var dashing: bool = false
@onready var wall_sliding: bool = false
@onready var can_dash: bool = false
@onready var can_move: bool = true
@onready var dead: bool = false
@onready var reached_finish: bool = false

# Colliders
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var hurt_box_collision_shape_2d: CollisionShape2D = $HurtBox/CollisionShape2D

# Animation and audio
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var running_sound: AudioStreamPlayer2D = $Audio/RunningSound
@onready var sliding_sound: AudioStreamPlayer2D = $Audio/SlidingSound
@onready var jump_sound: AudioStreamPlayer2D = $Audio/JumpSound
@onready var dead_sound: AudioStreamPlayer2D = $Audio/DeadSound
@onready var flip_sound: AudioStreamPlayer2D = $Audio/FlipSound


func _process(_delta: float) -> void:
	select_animation()
	flip_sprite()
	update_audio()


func _physics_process(delta: float) -> void:
	if not can_move:
		update_x_velocity(0, delta)
		apply_gravity(delta)
		move_and_slide()
		return
	
	move_left_right(delta)
	apply_gravity(delta)
	
	update_jump_buffer()
	update_wall_jump_buffer()
	update_coyote_timer()
	update_wall_coyote_timer()
	update_invert_coyote_timer()
	update_dash_allowed()
	
	try_jump()
	try_flip()
	
	move_and_slide()
	
	wall_sliding = is_on_wall_only() and Input.is_action_pressed("latch")


func _input(event: InputEvent) -> void:
	if not can_move: return
	if event.is_action_pressed("jump"):
		jump()
	elif event.is_action_pressed("flip_gravity"):
		flip_input()
	elif event.is_action_pressed("dash") or event.is_action_pressed("dash_chord"):
		dash()


### Animations functions
func select_animation():
	if dead: return
	if reached_finish:		animated_sprite_2d.play("Win")
	elif dashing:				animated_sprite_2d.play("Dash")
	elif is_on_floor():
		if velocity.x == 0:	animated_sprite_2d.play("Idle")
		else:				animated_sprite_2d.play("Run")
	elif wall_sliding:		animated_sprite_2d.play("Wall Slide")
	elif velocity.y < 0:	animated_sprite_2d.play("Jump")
	else:					animated_sprite_2d.play("Falling")


func flip_sprite():
	if velocity.x != 0:
		animated_sprite_2d.flip_h = velocity.x < 0
	animated_sprite_2d.flip_v = up_direction != Vector2.UP


### Audio functions
func update_audio() -> void:
	if wall_sliding:
		if not sliding_sound.playing:
			sliding_sound.play()
		running_sound.stop()
	elif velocity.x != 0 and is_on_floor():
		if not running_sound.playing:
			running_sound.play()
		sliding_sound.stop()
	else:
		running_sound.stop()
		sliding_sound.stop()


### Movement functions
func move_left_right(delta: float) -> void:
	var direction: float = Input.get_axis("left", "right")
	if not dashing:
		if is_on_floor():
			update_x_velocity(direction, delta)
		elif not wall_sliding and direction != 0:
			update_x_velocity(direction*air_control, delta)


func update_x_velocity(direction: float, delta: float) -> void:	
	if direction:
		velocity.x += direction * max_run_speed * delta / time_to_max_speed
		velocity.x = clamp(velocity.x, -max_run_speed, max_run_speed)
	else:
		if velocity.x > 0:
			velocity.x -= max_run_speed * delta / time_to_min_speed
			if velocity.x < 0: velocity.x = 0
		elif velocity.x < 0:
			velocity.x += max_run_speed * delta / time_to_min_speed
			if velocity.x > 0: velocity.x = 0
	
	if wall_sliding:
		velocity.x = 0


func apply_gravity(delta: float) -> void:
	if dashing: return
	if wall_sliding:
		wall_slide(delta)
	else:
		fall(delta)


func fall(delta: float) -> void:
	if Input.is_action_pressed("jump") and velocity.y*up_direction.y > 0:
		velocity.y -= delta*gravity*up_direction.y
	else:
		velocity.y -= delta*gravity*fall_multiplier*up_direction.y


### Jump functions
func jump() -> void:
	if is_on_floor() or coyote_avalible:
		velocity.y = up_direction.y * jump_height * gravity / 10
		jump_sound.play()
		clear_jump_buffers()
	elif wall_sliding or wall_coyote_avalible:
		velocity.y = up_direction.y * jump_height * gravity / 10
		velocity.x = get_wall_normal().x * wall_jump_out_force
		wall_sliding = false
		jump_sound.play()
		clear_jump_buffers()


func try_jump() -> void:
	if jump_buffer_avalible and is_on_floor():
		jump()
	elif wall_jump_buffer_avalible and is_on_wall():
		jump()


### Dash functions
func dash() -> void:
	if dashing or not can_dash: return
	if not (Input.is_action_pressed("dash") and Input.is_action_pressed("dash_chord")): return
	var direction: Vector2 = Vector2(Input.get_axis("left", "right"), Input.get_axis("up","down")).normalized()
	if direction != Vector2.ZERO:
		velocity = dash_boost*direction*max_run_speed
		dashing = true
		can_dash = false
		if can_dash_through_wall:
			collision_shape_2d.disabled = true
		hurt_box_collision_shape_2d.disabled = true
		await get_tree().create_timer(dash_time).timeout
		hurt_box_collision_shape_2d.disabled = false
		if can_dash_through_wall:
			collision_shape_2d.disabled = false
		dashing = false


### Invert functions
func flip() -> void:
	up_direction = -up_direction
	flip_sound.play()
	collision_shape_2d.position.y = -collision_shape_2d.position.y
	
	clear_jump_buffers()
	flip_buffer = 0
	flip_coyote_avalible = false
	flip_coyote_was_on_surface = false


func try_flip() -> void:
	if flip_buffer >= 2 and (is_on_floor() or wall_sliding or flip_coyote_avalible):
		flip()


func flip_input() -> void:
	flip_buffer = min(2, flip_buffer+1)
	await  get_tree().create_timer(flip_double_click_timer).timeout
	flip_buffer = max(0, flip_buffer-1)


### Wall slide functions
func wall_slide(delta: float) -> void:
	# Only slide if falling or player wants to
	if velocity.y*up_direction.y < 0:
		var slide_speed: float = Input.get_axis("slide_down", "slide_up")
		if round(slide_speed/abs(slide_speed)) == up_direction.y:
			velocity.y -= delta*gravity*up_direction.y*sqrt(abs(slide_speed))
		else:
			velocity.y -= delta*gravity*up_direction.y
			velocity.y = clamp(velocity.y, -max_wall_slide_speed, max_wall_slide_speed)
		
		velocity.x = -get_wall_normal().x
	else:
		fall(delta)


func update_dash_allowed() -> void:
	if is_on_floor():
		can_dash = true


### Buffer and Coyote functions
func update_jump_buffer() -> void:
	if is_on_wall():
		jump_buffer_avalible = false
		return
	if not is_on_floor() and Input.is_action_just_pressed("jump"):
		jump_buffer_avalible = true
		await get_tree().create_timer(jump_buffer).timeout
		jump_buffer_avalible = false


func update_wall_jump_buffer() -> void:
	if is_on_floor():
		wall_jump_buffer_avalible = false
		return
	if not is_on_wall_only() and Input.is_action_pressed("latch") and Input.is_action_just_pressed("jump"):
		wall_jump_buffer_avalible = true
		await get_tree().create_timer(jump_buffer).timeout
		wall_jump_buffer_avalible = false


func update_coyote_timer() -> void:
	if coyote_was_on_floor and not is_on_floor():
		coyote_was_on_floor = false
		coyote_avalible = true
		await get_tree().create_timer(coyote_time).timeout
		coyote_avalible = false
	else:
		coyote_was_on_floor = is_on_floor()


func update_wall_coyote_timer() -> void:
	if coyote_was_on_wall and not is_on_wall_only():
		wall_coyote_avalible = true
		await get_tree().create_timer(coyote_time).timeout
		wall_coyote_avalible = false
	coyote_was_on_wall = is_on_wall_only() and Input.is_action_pressed("latch")


func update_invert_coyote_timer() -> void:
	if flip_coyote_was_on_surface and not (is_on_floor() or wall_sliding):
		flip_coyote_was_on_surface = false
		flip_coyote_avalible = true
		await get_tree().create_timer(coyote_time).timeout
		flip_coyote_avalible = false
	else:
		flip_coyote_was_on_surface = is_on_floor() or wall_sliding


func clear_jump_buffers() -> void:
	await get_tree().create_timer(0.01).timeout # Need to wait until physics update happens so player has jumped and was_on vars don't get overwritten
	jump_buffer_avalible = false
	coyote_avalible = false
	coyote_was_on_floor = false
	
	wall_jump_buffer_avalible = false
	wall_coyote_avalible = false
	coyote_was_on_wall = false


### Functions to be called from outside player.gd
func finished() -> void:
	can_move = false
	reached_finish = true

func reset(start_position: Vector2) -> void:
	global_position = start_position
	velocity = Vector2.ZERO
	can_move = true
	reached_finish = false
	dead = false
	up_direction = Vector2.UP
	collision_shape_2d.position.y = abs(collision_shape_2d.position.y)


func _on_hurt_box_body_entered(_body: Node2D) -> void:
	can_move = false
	dead_sound.play()
	animated_sprite_2d.play("Death")
	dead = true
	Input.start_joy_vibration(0, 1, 0.5, 0.3)
	await animated_sprite_2d.animation_finished
	await get_tree().create_timer(0.5).timeout
	hit.emit()
	
