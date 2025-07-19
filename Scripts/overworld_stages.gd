extends AnimatedSprite2D

@export_file("*tscn") var levelPath:String = "res://Nodes/Scenes/Stages/_baseLevel.tscn"
@onready var levelNode = load(levelPath)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setAnimation()

func setAnimation():
	if stageAvailable():
		play("active")
	else:
		play("default")

func stageAvailable():
	var data = PlayerData.getStageData(levelNode.instantiate().get_scene_file_path())
	
	if data!=null and data["completed"] == true:
		return true
	
	return false

func goToLevel():
	TransitionScene.transitionToScene(levelPath)

func getLevelNode():
	return levelNode.instantiate()

func getLineRef():
	return $LineReference
