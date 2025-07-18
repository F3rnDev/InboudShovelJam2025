extends AnimatedSprite2D

@export_file("*tscn") var levelPath:String = "res://Nodes/Scenes/Stages/_baseLevel.tscn"
@onready var levelNode = load(levelPath)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play("active")

func goToLevel():
	TransitionScene.transitionToScene(levelPath)

func getLevelNode():
	return levelNode.instantiate()

func getLineRef():
	return $LineReference
