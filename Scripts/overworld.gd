extends Node2D

var selectedWorldID = 0

var canChange = true

enum worlds
{
	Tutorial,
	Lab #Just Testing it out btw
}

func _ready() -> void:
	setWorldGraphic()
	TransitionScene.fadeInOver.connect(setWorldGraphic)
	TransitionScene.fadeOutOver.connect(setCanChange)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Move Left") and canChange:
		setWorld(-1)
		
	if Input.is_action_just_pressed("Move Right") and canChange:
		setWorld(1)
	
	if Input.is_action_just_pressed("Cancel"):
		TransitionScene.transitionToScene("res://Nodes/Scenes/mainMenu.tscn")

func setWorld(addTo):
	setCanChange(false)
	
	var newWorldID = selectedWorldID + addTo
	var worldAmount = worlds.size() - 1
	
	if newWorldID > worldAmount:
		newWorldID = 0
	elif newWorldID < 0:
		newWorldID = worldAmount
	
	selectedWorldID = newWorldID
	
	TransitionScene.transitionInsideScene()

func setWorldText():
	var curWorldName = worlds.find_key(selectedWorldID)
	$HUD/WorldName.text = "← " + curWorldName + " →"

func setWorldGraphic():
	setWorldText()
	
	var curWorld = "Background" + worlds.find_key(selectedWorldID)
	
	for background in $Backgrounds.get_children():
		var displayBackground = false
		
		if background.name == curWorld:
			displayBackground = true
		
		background.visible = displayBackground
		for element in background.get_children():
			element.visible = displayBackground

func setCanChange(change:bool = true):
	canChange = change
