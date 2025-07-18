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

func _ready() -> void:
	setStageLines()
	setPlayerPosition()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $Player.position != playerPos:
		$Player.position = $Player.position.move_toward(playerPos, playerSpeed * delta)
	
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
		TransitionScene.transitionToScene("res://Nodes/Scenes/mainMenu.tscn")

func setStage(addTo):
	var newStageID = selectedStageID + addTo
	var StageAmount = $Stages.get_child_count() - 1
	
	if newStageID > StageAmount:
		newStageID = StageAmount
	elif newStageID < 0:
		newStageID = 0
	
	selectedStageID = newStageID

func setPlayerPosition():
	var newPos = $Stages.get_child(selectedStageID).global_position
	playerPos = Vector2(newPos.x, newPos.y - playerYOffset)

func setStageText():
	var stageNode = $Stages.get_child(selectedStageID).getLevelNode()
	var stageName = stageNode.name
	$HUD/StageName.text = "- " + stageName + " -"

func playStage():
	$Stages.get_child(selectedStageID).goToLevel()

func setStageLines():
	for stage in $Stages.get_children():
		$StageConnection.add_point(stage.getLineRef().global_position)
