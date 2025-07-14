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

func _ready() -> void:
	$LaserGreen2.modulate.a = 0.0

func _physics_process(delta: float) -> void:
	Movement(delta)
	CaptureInput(delta)
	move_and_slide()

func _process(delta: float) -> void:
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
		
		if !animated:
			$LaserGreen2/AnimationPlayer.play("Open")
			animated = true
	else:
		$LaserGreen2.modulate.a = lerp($LaserGreen2.modulate.a, 0.0, 10 * delta)
		$LaserGreen2/AnimationPlayer.play("Close")
		animated = false


func _on_laser_area_entered(area: Area2D) -> void:
	area.get_parent().isBeingCaptured = false
	
	if captureMode:
		area.get_parent().isBeingCaptured = true


func _on_laser_area_exited(area: Area2D) -> void:
	area.get_parent().isBeingCaptured = false

func _on_capture_area_entered(area: Area2D) -> void:
	enemiesCaptured += 1
	area.get_parent().dieAnimation()
