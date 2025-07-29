extends CharacterBody2D

@export var animations:AnimatedSprite2D
@export var animationsTransform:AnimationPlayer
var player
var isBeingCaptured:bool = false
var abductionSpeed:int = 200
var stun:bool = false
var dead:bool = false
var initialPos:Vector2

func _ready() -> void:
	initialPos = global_position

func _process(delta: float) -> void:
	player = get_parent().playerRef
	
	if !player.captureMode:
		isBeingCaptured = false
	
	IsStunned()
	pass

func _physics_process(delta: float) -> void:
	if isBeingCaptured:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * abductionSpeed
	else:
		if is_on_floor():
			velocity = Vector2.ZERO
		else:
			velocity += get_gravity() * delta
	
	move_and_slide()


func IsStunned():
	modulate.a = 1.0
	
	if stun:
		modulate.a = 0.3
	elif !isBeingCaptured and !stun:
		animations.play("idle")
	else:
		animations.stop()

func Die():
	if dead:
		animationsTransform.play("die")
		if animationsTransform.animation_finished:
			queue_free()
	
	if global_position.y >= 1900:
		global_position = initialPos
