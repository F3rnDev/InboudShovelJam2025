extends Node2D
#do things like win game and game over stuff
#call signals on other objects
var gameOver = false
var maxEnemies = 0

signal wonGame

func _ready() -> void:
	setMaxEnemies()
	$HUD.setCapturedEnemies(maxEnemies)

func setMaxEnemies():
	maxEnemies = $EnemyGroup.get_child_count()

func _process(delta: float) -> void:
	if gameOver and Input.is_action_just_pressed("Reset"):
		get_tree().reload_current_scene()

func _on_player_entered_ufo() -> void:
	$GameCamera.changePlayer(1)
	
	if maxEnemies <= 0:
		winGame()

func _on_player_player_dead() -> void:
	gameOver = true

func _on_player_hit(health) -> void:
	$GameCamera.shakeCamera()
	$HUD.updateHealth(health)

func _on_player_ufo_enemy_captured(captureAmount: int) -> void:
	var enemiesLeft = maxEnemies - captureAmount
	$HUD.setCapturedEnemies(enemiesLeft)
	
	if enemiesLeft <= 0:
		winGame()

func winGame():
	wonGame.emit()
