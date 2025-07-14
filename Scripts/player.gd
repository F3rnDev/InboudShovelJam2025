extends CharacterBody2D


@export var SPEED = 800.0
@export var JUMP_VELOCITY = -500.0
@export var acceleration = 800.0
@export var frictionMult = 4

@export var jumpAmount:int = 2
var jumps = jumpAmount

@export var fastFallMultiplier = 2.0

#Wall jump/slide
@export var wallJumpPush = 500.0;
@export var wallSlideGravity = 100.0
var isWallSliding = false

func _process(delta: float) -> void:
	Animate()

func _physics_process(delta: float) -> void:
	HorizontalMovement(delta)
	VerticalMovement(delta)

	move_and_slide()

func HorizontalMovement(delta):
	var direction = Input.get_axis("Move Left", "Move Right")
	var targetSpeed = direction * SPEED
	if direction:
		var changing_direction = sign(direction) != sign(velocity.x) and abs(velocity.x) > 10
		var effective_accel = acceleration * 3.0 if changing_direction else acceleration
		velocity.x = move_toward(velocity.x, targetSpeed, effective_accel * delta)
	else:
		velocity.x *= lerp(1.0, 0.0, delta * frictionMult)
	
	if abs(velocity.x) < 1.0:
		velocity.x = 0

func VerticalMovement(delta):
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
	if Input.is_action_just_pressed("Jump"):
		Jump()
	
	#Stop jump if button is released
	if Input.is_action_just_released("Jump") and velocity.y < 0:
		velocity.y = 0
	
	#Wall slide
	WallSlide(delta)

func Jump():
	if !is_on_floor() and jumps == jumpAmount:
		jumps = jumpAmount-1
	
	var direction = Input.get_axis("Move Left", "Move Right")
	if is_on_wall() and !is_on_floor() and direction!=0:
		jumps = jumpAmount
		velocity.x += -wallJumpPush * direction
	
	if jumps > 0:
		velocity.y = JUMP_VELOCITY
		jumps -= 1

func WallSlide(delta):
	if is_on_wall() and !is_on_floor() and !$RayCast2D.is_colliding():
		var direction = Input.get_axis("Move Left", "Move Right")
		if direction != 0:
			isWallSliding = true
		else:
			isWallSliding = false
	else:
		isWallSliding = false
	
	if isWallSliding:
		velocity.y += wallSlideGravity * delta
		velocity.y = min(velocity.y, wallSlideGravity)

func Animate():
	#Animate character
	var direction = Input.get_axis("Move Left", "Move Right")
	if is_on_floor():
		if direction < 0 or direction > 0:
			$AnimatedSprite2D.play("Walk")
		else:
			$AnimatedSprite2D.play("Idle")
	else:
		$AnimatedSprite2D.play("Jump")
	
	#Flip sprite
	if direction < 0:
		$AnimatedSprite2D.flip_h = true
	elif direction > 0:
		$AnimatedSprite2D.flip_h = false
