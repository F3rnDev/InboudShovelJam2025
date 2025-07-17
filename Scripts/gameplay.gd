extends Node2D

#Stage data
@export var stageID:int
@export var stageName:String

#do things like win game and game over stuff
#call signals on other objects
var gameOver = false
var maxEnemies = 0

var hasWin = false

signal wonGame

func _ready() -> void:
	setMaxEnemies()
	$HUD.setCapturedEnemies(maxEnemies)
	$HUD.setStageText(stageName)

func setMaxEnemies():
	maxEnemies = $EnemyGroup.get_child_count()

func _process(delta: float) -> void:
	if gameOver and Input.is_action_just_pressed("Reset"):
		TransitionScene.transitionToSameScene()
	
	if hasWin and Input.is_action_just_pressed("Confirm"):
		goToNextStage()

func goToNextStage():
	var stagePath = "res://Nodes/Scenes/Stages/" + str(stageID+1) + ".tscn"
	
	if ResourceLoader.exists(stagePath):
		TransitionScene.transitionToScene(stagePath)
	else:
		print("stage doesn't exist")

func _on_player_entered_ufo() -> void:
	$GameCamera.changePlayer(1)
	$PlayerUFO.setPlayerSprite(false)
	
	if maxEnemies <= 0:
		winGame()
	else:
		$HUD.setCaptureThemText()

func _on_hud_capture_them_signal() -> void:
	$PlayerUFO.setPlayerMovement(false)

func _on_player_player_dead() -> void:
	gameOver = true
	$HUD.setGameOverText()

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
	hasWin = true
	
	$HUD.setGameWinText()
