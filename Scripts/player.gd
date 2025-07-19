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
@export var playerInactive = false
var gameOver = false

@export var health = 3
var invulnerable = false
var wasHit = false

signal enteredUFO
signal playerDead
signal hit(curHealth:int)

var afterImage = false

#Coyote Time
var wasOnFloor = false

func _ready() -> void:
	if playerInactive:
		$AnimatedSprite2D.play("Idle")

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
	
	if afterImage:
		spawn_afterimage()

func _physics_process(delta: float) -> void:
	if !playerInactive:
		HorizontalMovement(delta)
	
	VerticalMovement(delta)
	
	if global_position.y >= 1900 and !gameOver:
		wasHit = true
		hit.emit(0)
		killPlayer()
	
	if is_on_floor() or is_on_wall() or velocity.y > 0:
		afterImage = false

	move_and_slide()

func HorizontalMovement(delta):
	var direction = Input.get_axis("Move Left", "Move Right")
	var targetSpeed = direction * SPEED
	if direction and !wasHit and !gameOver:
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
	
	if playerInactive:
		return
	
	# Handle jump/jumpBuffer
	if Input.is_action_just_pressed("Jump") and jumps == 0:
		$JumpBuffer.start()
	elif Input.is_action_just_pressed("Jump") and jumps > 0:
		Jump()
	
	if !$JumpBuffer.is_stopped() and (is_on_floor() or is_on_wall()):
		Jump()
	
	#Stop jump if button is released
	if Input.is_action_just_released("Jump") and velocity.y < 0:
		velocity.y = 0
	
	#Coyotte time
	if !is_on_floor() and wasOnFloor:
		$CoyotteTime.start()
	
	wasOnFloor = is_on_floor()
	
	#Set jumpAmount if player fell down a platform
	if !is_on_floor() and jumps == jumpAmount and $CoyotteTime.is_stopped():
		jumps = jumpAmount-1
	
	#Wall slide
	WallSlide(delta)

func Jump():
	if wasHit or gameOver:
		return
	
	$CoyotteTime.stop()
	$JumpBuffer.stop()
	
	var direction = Input.get_axis("Move Left", "Move Right")
	if is_on_wall() and !is_on_floor():
		jumps = jumpAmount
		velocity.x += -wallJumpPush * direction
	
	if jumps > 0:
		velocity.y = JUMP_VELOCITY
		jumps -= 1
		
		if jumps == 0:
			afterImage = true

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

func enterUFO():
	enteredUFO.emit()
	queue_free()

func playerHit(enemyPos):
	if invulnerable:
		return
	
	health -= 1
	invulnerable = true
	wasHit = true
	
	hit.emit(health)
	
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
	
	var playerDir = -1 if $AnimatedSprite2D.flip_h else 1
	var knockbackStrength = Vector2(0, -600)
	velocity = knockbackStrength
	
	$CollisionShape2D.set_deferred("disabled", true)
	$Hitbox/CollisionShape2D.set_deferred("disabled", true)
	$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
	set_process(true)
	
	playerDead.emit()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("UFO"):
		enterUFO()
	if area.get_parent().is_in_group("Enemy"):
		playerHit(area.global_position)

func _on_enemy_enemyhit() -> void:
	velocity.y = JUMP_VELOCITY
	jumps = jumpAmount-1

func spawn_afterimage():
	var ghost := Sprite2D.new()
	
	# Copia a aparência do jogador
	ghost.texture = $AnimatedSprite2D.sprite_frames.get_frame_texture(
		$AnimatedSprite2D.animation,
		$AnimatedSprite2D.frame
	)
	ghost.flip_h = $AnimatedSprite2D.flip_h
	ghost.scale = $AnimatedSprite2D.scale
	ghost.global_position = global_position
	ghost.rotation = rotation
	ghost.modulate = Color(0.49, 0.96, 0.82, 0.2)  # semi-transparente
	ghost.z_index = $AnimatedSprite2D.z_index - 1

	# Adiciona no mesmo pai
	get_parent().add_child(ghost)

	# Cria tween para sumir suavemente
	var tween := get_tree().create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, 0.3)
	tween.tween_callback(Callable(ghost, "queue_free"))

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		playerHit(global_position)
