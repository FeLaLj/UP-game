extends CharacterBody2D

# Constants
const speed = 550
const jump_power = -2000
const acc = 50
const friction = 70
const gravity = 120
const wall_jump_pushback = 500
const wall_slide_gravity = 300
const max_fall_speed = 800

# Variables
var is_wall_sliding = false

func _physics_process(_delta):
	var input_dir = input()
	
	if input_dir != Vector2.ZERO:
		accelerate(input_dir)
	else:
		add_friction()
	
	apply_gravity()
	wall_slide()
	jump()
	
	# Move character
	move_and_slide()

# Handles player input
func input() -> Vector2:
	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_axis("ui_left", "ui_right")
	return input_dir.normalized()

# Handles player acceleration
func accelerate(direction):
	velocity = velocity.move_toward(speed * direction, acc)

# Applies friction when no input is given
func add_friction():
	velocity = velocity.move_toward(Vector2.ZERO, friction)

# Applies gravity unless the character is wall-sliding
func apply_gravity():
	if !is_wall_sliding:
		velocity.y += gravity

# Handles player jumping
func jump():
	if Input.is_action_just_pressed("ui_up"):
		if is_on_floor():
			velocity.y = jump_power
		elif is_touching_wall():
			velocity.y = jump_power
			velocity.x = -wall_jump_pushback if velocity.x > 0 else wall_jump_pushback

# Wall sliding logic
func wall_slide():
	if is_touching_wall() and !is_on_floor():
		is_wall_sliding = true
		# Apply reduced gravity when sliding
		velocity.y += wall_slide_gravity * 0.1
		# Clamp the fall speed to avoid rapid falling
		velocity.y = min(velocity.y, max_fall_speed)
	else:
		is_wall_sliding = false

# Checks for wall collisions based on collision normals
func is_touching_wall() -> bool:
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		# Detects if the normal is nearly horizontal (touching a wall)
		if abs(collision.get_normal().x) > 0.9:
			return true
	return false
