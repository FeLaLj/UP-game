extends CharacterBody2D

const speed = 550.0
const jump_power = -2000.0

const acc = 50.0
const friction = 70.0
const gravity = 120.0

const wall_jump_pushback = 100.0
const max_fall_speed = 800
const wall_slide_gravity = 300.0

var is_wall_sliding = false

func _physics_process(delta):
	var input_dir = input()

	if input_dir != Vector2.ZERO:
		accelerate(input_dir)
	else:
		add_friction()
	
	apply_gravity()
	jump()
	wall_slide()
	move_and_slide()

func player_movement():
	move_and_slide()

func accelerate(direction):
	velocity = velocity.move_toward(speed * direction, acc)

func add_friction():
	velocity = velocity.move_toward(Vector2.ZERO, friction)

func apply_gravity():
	if !is_wall_sliding:
		velocity.y += gravity

func input() -> Vector2:
	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_axis("ui_left", "ui_right")
	return input_dir.normalized()


func jump():
	velocity.y += gravity
	if Input.is_action_just_pressed("ui_up"):
		if is_on_floor():
			velocity.y = jump_power
	elif is_on_wall():
		if Input.is_action_pressed("ui_right"):
			velocity.y = jump_power
			velocity.y = -wall_jump_pushback
		elif Input.is_action_pressed("ui_left"):
			velocity.y = jump_power
			velocity.x = wall_jump_pushback

func is_touching_wall() -> bool:
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		#check collision y axis
		if abs(collision.normal.x) > 0.9:
			return true
	return false

func wall_slide():
	if is_on_wall() and !is_on_floor() and Input.get_axis("ui_left", "ui_right") != 0:
		is_wall_sliding = true
	else:
		is_wall_sliding = false
	if is_wall_sliding:
		velocity.y += wall_slide_gravity * 0.1
		velocity.y = min(velocity.y, max_fall_speed)
