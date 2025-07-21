extends Node2D

var selectedStageID = 0

enum Stages
{
	Tutorial,
	Lab #Just Testing it out >:D
}

#player
@export var playerYOffset = 100
@export var playerSpeed = 100
var playerPos

#playerTilting
@export var tilt_amount := 25.0 # graus
@export var tilt_speed := 10.0

func _ready() -> void:
	setDefaultStage()
	
	setStageLines()
	setPlayerPosition()
	setStageText()
	
	$Player.position = playerPos

func setDefaultStage():
	if PlayerData.lastSelectedStage == null:
		setDefaultStageByLast()
	else:
		setDefaultStageBySavedData()

func setDefaultStageByLast():
	var currentID = 0
	
	for stageID in $Stages.get_child_count():
		var stage = $Stages.get_child(stageID)
		
		if stage.stageAvailable():
			currentID = stageID
	
	selectedStageID = currentID

func setDefaultStageBySavedData():
	var foundStage = false
	
	for stageID in $Stages.get_child_count():
		var stage = $Stages.get_child(stageID)
		var stageData = stage.levelNode.instantiate().get_scene_file_path()
		
		if PlayerData.lastSelectedStage == stageData:
			selectedStageID = stageID
			foundStage = true
			break
	
	if !foundStage:
		setDefaultStageByLast()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#PLAYER
	if $Player.position != playerPos:
		$Player.position = $Player.position.move_toward(playerPos, playerSpeed * delta)
	
	var direction = sign(playerPos.x - $Player.position.x)
	var target_rotation = deg_to_rad(tilt_amount * direction)

	$Player.rotation = lerp($Player.rotation, target_rotation, delta * tilt_speed)
	
	#INPUT	
	if Input.is_action_just_pressed("Move Left"):
		setStage(-1)
		setStageText()
		setPlayerPosition()
		
	if Input.is_action_just_pressed("Move Right"):
		setStage(1)
		setStageText()
		setPlayerPosition()
	
	if Input.is_action_just_pressed("Confirm"):
		playStage()
	
	if Input.is_action_just_pressed("Cancel"):
		$Audio/CancelSfx.play()
		TransitionScene.transitionToScene("res://Nodes/Scenes/mainMenu.tscn")

func setStage(addTo):
	var newStageID = selectedStageID + addTo
	var StageAmount = $Stages.get_child_count() - 1
	
	if newStageID > StageAmount:
		newStageID = StageAmount
	elif newStageID < 0:
		newStageID = 0
	
	#check if you have stage available
	for stageID in $Stages.get_child_count():
		var stage = $Stages.get_child(stageID)
		
		if !stage.stageAvailable() and newStageID > stageID:
			newStageID = stageID
			break
	
	if selectedStageID != newStageID:
		$Audio/SelectSfx.play()
	
	selectedStageID = newStageID

func setPlayerPosition():
	var newPos = $Stages.get_child(selectedStageID).global_position
	playerPos = Vector2(newPos.x, newPos.y - playerYOffset)

func setStageText():
	var stageNode = $Stages.get_child(selectedStageID).getLevelNode()
	var stageName = stageNode.name
	$HUD/StageName.text = "- " + stageName + " -"

func playStage():
	$Audio/ConfirmSfx.play()
	$Stages.get_child(selectedStageID).goToLevel()

func setStageLines():
	var selectedLastStage = false
	
	for stage in $Stages.get_children():
		if !stage.stageAvailable() and selectedLastStage:
			break
		elif !stage.stageAvailable() and !selectedLastStage:
			selectedLastStage = true
		
		$StageConnection.add_point(stage.getLineRef().global_position)
