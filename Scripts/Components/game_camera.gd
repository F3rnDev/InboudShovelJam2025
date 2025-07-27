extends Camera2D

@export var playerRef:CharacterBody2D
@export var playerUFORef:CharacterBody2D

var playerToFollow:CharacterBody2D

#camera shake
@export var rngStr:float = 20.0
@export var shakeFade:float = 5.0

var rng = RandomNumberGenerator.new()
var shakeStr = 0.0

func _ready() -> void:
	changePlayer(0)
	position = playerToFollow.position
	position_smoothing_enabled = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = playerToFollow.position
	
	if position == playerToFollow.position and !position_smoothing_enabled:
		position_smoothing_enabled = true
	
	if shakeStr > 0:
		shakeStr = lerpf(shakeStr, 0, shakeFade * delta)
		offset = randomOffset()

func changePlayer(playerID):
	match playerID:
		0:
			playerToFollow = playerRef
		1:
			playerToFollow = playerUFORef

func shakeCamera():
	shakeStr = rngStr

func randomOffset() -> Vector2:
	return Vector2(rng.randf_range(-shakeStr, shakeStr), rng.randf_range(-shakeStr, shakeStr))
