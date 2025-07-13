extends CharacterBody2D


@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0
@export var acceleration = 800.0
@export var friction = 1000.0

@export var jumpAmount:int = 2
var jumps = jumpAmount

@export var fastFallMultiplier = 2.0

func _process(delta: float) -> void:
	Animate()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	var fastFall = 1
	if velocity.y > 0:
		fastFall = fastFallMultiplier
	
	if not is_on_floor():
		velocity += get_gravity() * fastFall * delta
	else:
		velocity.y = 0
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
	var targetSpeed = direction * SPEED
	if direction:
		velocity.x = move_toward(velocity.x, targetSpeed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	move_and_slide()

func Animate():
	#Animate character
	if is_on_floor():
		if velocity.x != 0:
			$AnimatedSprite2D.play("Walk")
		else:
			$AnimatedSprite2D.play("Idle")
	else:
		$AnimatedSprite2D.play("Jump")
	
	#Flip sprite
	if velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
	elif velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
