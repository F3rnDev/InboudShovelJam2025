extends Node2D

#Stage data
@export_file("*tscn") var nextStage:String
@onready var stageData = {
	"stageName" = self.name,
	"stagePath" = self.get_scene_file_path(),
	"completed" = false
}

#do things like win game and game over stuff
#call signals on other objects
var gameOver = false
var maxEnemies = 0

var hasWin = false

signal wonGame

func _ready() -> void:
	setMaxEnemies()
	$HUD.setCapturedEnemies(maxEnemies)
	$HUD.setStageText(name)
	
	PlayerData.lastSelectedStage = get_scene_file_path()

func setMaxEnemies():
	maxEnemies = $EnemyGroup.get_child_count()

func _process(delta: float) -> void:
	if gameOver and Input.is_action_just_pressed("Reset"):
		TransitionScene.transitionToScene(get_tree().current_scene.scene_file_path)
	
	if hasWin and Input.is_action_just_pressed("Confirm"):
		goToNextStage()

func goToNextStage():
	if ResourceLoader.exists(nextStage):
		TransitionScene.transitionToScene(nextStage)
	else:
		TransitionScene.transitionToScene("res://Nodes/Scenes/overworld.tscn")

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
	
	stageData["completed"] = true
	PlayerData.setStageData(stageData)
	
	$HUD.setGameWinText()
