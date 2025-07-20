extends CharacterBody2D

@export var speed = 800.0
@export var acceleration = 1500.0
@export var frictionMult = 7

#Tilting
@export var tilt_amount := 25.0 # graus
@export var tilt_speed := 10.0

#Capturing enemies
var captureMode = false
var animated

#Capture score
var enemiesCaptured = 0

#Inactive
var playerInactive = true

#Player won
var playerWon = false

#Health
@export var shipHealth = 3 #Not planned, could be something

signal enemyCaptured(captureAmount:int)

@export var camera:Camera2D

func _ready() -> void:
	$LaserGreen2.modulate.a = 0.0
	$AnimatedSprite2D.play("inactive")

func setPlayerMovement(active:bool):
	playerInactive = active

func setPlayerSprite(active:bool):
	var curAnimString = "default" if !active else "inactive"
	
	$AnimatedSprite2D.play(curAnimString)

func _physics_process(delta: float) -> void:
	if !playerInactive:
		Movement(delta)
		CaptureInput(delta)
	
	if playerWon:
		var direction = Vector2(0, -1)
		$"Audio/Ufo Capture".stop()
		velocity = velocity.move_toward(direction * speed * 2, acceleration * delta)
	
	if !playerInactive or playerWon: 
		#PlaySound
		if !$"Audio/Ufo Engine".playing:
			$"Audio/Ufo Engine".play()
		
		#Set Pitch
		var speed_factor = velocity.length() / speed
		speed_factor = clamp(speed_factor, 0.5, 2.0)

		$"Audio/Ufo Engine".pitch_scale = speed_factor
		
		#Set Volume
		if position.y < camera.limit_top and $"Audio/Ufo Engine".volume_db > -80.0:
			$"Audio/Ufo Engine".volume_db -= 20.0 * delta
		
	move_and_slide()

func _process(delta: float) -> void:
	if !playerInactive:
		TiltSprite(delta)

func Movement(delta):
	var directionX = Input.get_axis("Move Left", "Move Right")
	var directionY = Input.get_axis("Move Up", "Move Down")
	
	var direction = Vector2(directionX, directionY).normalized()
	
	var actualSpeed = speed
	if captureMode:
		actualSpeed = speed/2
	
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * actualSpeed, acceleration * delta)
	else:
		velocity *= lerp(1.0, 0.0, delta * frictionMult)
	
	#limitMovement
	position.x = clamp(position.x, camera.limit_left, camera.limit_right)
	position.y = clamp(position.y, camera.limit_top, camera.limit_bottom)

func TiltSprite(delta):
	var sprite = $AnimatedSprite2D
	
	var directionX = Input.get_axis("Move Left", "Move Right")
	var target_tilt = 0.0
	
	if abs(velocity.x) > 5 and !captureMode:
		target_tilt = sign(directionX) * deg_to_rad(tilt_amount)

	sprite.rotation = lerp_angle(sprite.rotation, target_tilt, tilt_speed * delta)

func CaptureInput(delta):
	captureMode = Input.is_action_pressed("Jump")
	if captureMode:
		$LaserGreen2.modulate.a = lerp($LaserGreen2.modulate.a, 1.0, 10 * delta)
		openLaser()
	else:
		$LaserGreen2.modulate.a = lerp($LaserGreen2.modulate.a, 0.0, 10 * delta)
		closeLaser()
		$"Audio/Ufo Capture".stop()
	
	if !$"Audio/Ufo Capture".playing and captureMode:
		$"Audio/Ufo Capture".play()

func openLaser():
	if !animated:
		$LaserGreen2/AnimationPlayer.play("Open")
		animated = true

func closeLaser():
	$LaserGreen2/AnimationPlayer.play("Close")
	animated = false


func _on_laser_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("Enemy"):
		area.get_parent().isBeingCaptured = false
		
		if captureMode:
			area.get_parent().isBeingCaptured = true


func _on_laser_area_exited(area: Area2D) -> void:
	if area.get_parent().is_in_group("Enemy"):
		area.get_parent().isBeingCaptured = false

func _on_capture_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("Enemy") and captureMode:
		enemiesCaptured += 1
		enemyCaptured.emit(enemiesCaptured)
		$Audio/EnemiesCaptured.play()
		area.get_parent().dieAnimation()

func _on_main_won_game() -> void:
	playerInactive = true
	closeLaser()
	$CollisionShape2D.set_deferred("disabled", true)
	$"Capture Area".set_deferred("disabled", true)
	
	playerWon = true
	captureMode = false
