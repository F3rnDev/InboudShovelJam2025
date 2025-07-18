extends Node2D

func _ready() -> void:
	#set the play button with focus
	$CanvasLayer/Options/Play.grab_focus()

func _on_play_button_down() -> void:
	TransitionScene.transitionToScene("res://Nodes/Scenes/overworld.tscn")

func _on_exit_button_down() -> void:
	get_tree().quit()
