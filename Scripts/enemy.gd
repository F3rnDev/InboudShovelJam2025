extends CharacterBody2D

const SPEED = 100.0
@export var playerRef:CharacterBody2D
var isBeingCaptured = false
@export var abductionSpeed = 200
var direction = -1

@onready var wallRay = $RayCastWall
@onready var floorRay = $RayCastFloor

func _process(delta: float) -> void:
	$AnimatedSprite2D.flip_h = direction > 0
	
	if !isBeingCaptured:
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.stop()
	
	if !playerRef.captureMode:
		isBeingCaptured = false

func _physics_process(delta: float) -> void:
	if isBeingCaptured:
		var direction = (playerRef.global_position - global_position).normalized()
		velocity = direction * abductionSpeed
	else:
		verticalMovement(delta)
		horizontalMovement(delta)

	move_and_slide()

func verticalMovement(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0

func horizontalMovement(delta):
	wallRay.target_position = Vector2(wallRay.target_position.x * direction, wallRay.target_position.y)
	
	if wallRay.is_colliding() or (!floorRay.is_colliding() and is_on_floor()):
		direction *= -1
	
	velocity.x = direction * SPEED

func dieAnimation():
	$AnimatedSprite2D/AnimationPlayer.play("die")

func _on_die_animation_finished(anim_name: StringName) -> void:
	queue_free()
