extends CharacterBody2D

const SPEED = 100.0
var playerRef
var isBeingCaptured = false
@export var abductionSpeed = 200
var direction = -1

@onready var wallRay = $RayCastWall
@onready var floorRay = $RayCastFloor

var stunned = false
var dead = false

var initialPos

func _ready() -> void:
	initialPos = global_position

func _process(delta: float) -> void:
	$AnimatedSprite2D.flip_h = direction > 0
	
	if !isBeingCaptured and velocity.x != 0:
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.stop()
	
	playerRef = get_parent().playerRef
	
	if !playerRef.captureMode:
		isBeingCaptured = false
	
	if stunned:
		modulate.a = 0.3
	else:
		modulate.a = 1.0
	
	if global_position.y >= 1900:
		global_position = initialPos

func _physics_process(delta: float) -> void:
	if isBeingCaptured:
		var direction = (playerRef.global_position - global_position).normalized()
		velocity = direction * abductionSpeed
	else:
		verticalMovement(delta)
		
		if !stunned:
			horizontalMovement(delta)
		else:
			velocity.x = 0

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
	dead = true

func _on_die_animation_finished(anim_name: StringName) -> void:
	queue_free()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("Player") and area.get_parent().velocity.y >= 0:
		$AnimatedSprite2D.play("hit")
		stunned = true
		$Hitbox/CollisionShape2D.set_deferred("disabled", true)
		get_parent().enemyhit.emit()
		$Timer.start()

func _on_timer_timeout() -> void:
	stunned = false
	$Hitbox/CollisionShape2D.set_deferred("disabled", false)
