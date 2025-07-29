extends CharacterBody2D

@export var animations:AnimatedSprite2D
@export var animationsTransform:AnimationPlayer
@export var stunCooldown:Timer
@export var collisionHitbox:CollisionShape2D
var playerUFO:CharacterBody2D
var abductionSpeed:int = 200
var isBeingCaptured:bool = false
var stun:bool = false
var dead:bool = false
var initialPos:Vector2

func _ready() -> void:
	initialPos = global_position

func _process(delta: float) -> void:
	Respawn()
	Stunned()

func _physics_process(delta: float) -> void:
	BeingCaptured(delta)

func BeingCaptured(delta):
	playerUFO = get_parent().playerRef
	var direction:Vector2 = (playerUFO.global_position - global_position).normalized()
	
	if playerUFO.captureMode and isBeingCaptured:
		velocity = direction * abductionSpeed
	else:
		if is_on_floor():
			velocity = Vector2.ZERO
		else:
			velocity += get_gravity() * delta
	
	move_and_slide()

func Stunned():
	if stun: 
		animations.play("hit")
		collisionHitbox.set_deferred("disabled", true)
		modulate.a = 0.3
	else:
		animations.play("idle")
		collisionHitbox.set_deferred("disabled", false)
		modulate.a = 1.0

func Respawn():
	if global_position.y >= playerUFO.camera.limit_bottom:
		global_position = initialPos

func dieAnimation():
	if dead:
		animationsTransform.play("die")
		if !animationsTransform.is_playing():
			queue_free()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("Player"):
		stun = true
		get_parent().enemyhit.emit()
		stunCooldown.start()

func _on_timer_timeout() -> void:
	stun = false
