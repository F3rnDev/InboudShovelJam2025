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

#playerActive
var playerInactive = false
var gameOver = false

@export var health = 3
var invulnerable = false
var wasHit = false

signal enteredUFO
signal playerDead
signal hit

func _process(delta: float) -> void:
	if !playerInactive and !wasHit:
		Animate()
	
	if wasHit and is_on_floor() and !gameOver:
		wasHit = false
		$AnimatedSprite2D.modulate = Color(1, 1, 1, 1)
	
	if wasHit:
		$AnimatedSprite2D.play("Hit")
	
	if gameOver:
		rotation_degrees += 1

func _physics_process(delta: float) -> void:
	if !playerInactive:
		HorizontalMovement(delta)
		VerticalMovement(delta)

	move_and_slide()

func HorizontalMovement(delta):
	var direction = Input.get_axis("Move Left", "Move Right")
	var targetSpeed = direction * SPEED
	if direction and !wasHit:
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
	elif not is_on_floor() and !wasHit:
		velocity.y = 0
	else:
		jumps = jumpAmount
	
	# Handle jump.
	if Input.is_action_just_pressed("Jump") and !wasHit:
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

func enterUFO(ufo):
	ufo.setPlayer(false)
	visible = false
	playerInactive = true
	enteredUFO.emit()

func playerHit(enemyPos):
	if invulnerable:
		return
	
	health -= 1
	invulnerable = true
	wasHit = true
	
	hit.emit()
	
	if health <= 0:
		killPlayer()
		return
	
	#Player Knockback
	var knockbackDirection = (global_position - enemyPos).normalized()
	var knockbackStrength = Vector2(knockbackDirection.x * 1000, -200)
	velocity = knockbackStrength
	
	#Blink player
	var blink_timer := 0.6
	var blink_interval := 0.1
	var blink := true

	while blink_timer > 0:
		$AnimatedSprite2D.modulate.a = 1.0 if blink else 0.3
		blink = !blink
		await get_tree().create_timer(blink_interval).timeout
		blink_timer -= blink_interval
	
	#After blink, let player be vulnerable
	invulnerable = false

func killPlayer():
	gameOver = true
	$AnimatedSprite2D.play("Hit")
	
	var playerDir = -1 if $AnimatedSprite2D.flip_h else 1
	var knockbackStrength = Vector2(0, -600)
	velocity = knockbackStrength
	
	$CollisionShape2D.set_deferred("disabled", true)
	
	playerDead.emit()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("UFO"):
		enterUFO(area.get_parent())
	if area.get_parent().is_in_group("Enemy"):
		playerHit(area.global_position)


func _on_enemy_enemyhit() -> void:
	velocity.y = JUMP_VELOCITY
	jumps = jumpAmount-1
