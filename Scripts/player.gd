extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export var jumpAmount:int = 2
var jumps = jumpAmount

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity = Vector2(0, 0)
		jumps = jumpAmount

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and jumps > 0:
		velocity.y = JUMP_VELOCITY
		jumps -= 1
	elif Input.is_action_just_released("Jump") and velocity.y < 0:
		velocity.y = 0

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("Move Left", "Move Right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
