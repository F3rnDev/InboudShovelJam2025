extends Node2D

var inOptions = false

func _ready() -> void:
	#set the play button with focus
	$MenuCanvas/Options/Play.grab_focus()
	$Options.visible = false
	
	if OS.has_feature("web"):
		$MenuCanvas/Options/Exit.visible = false

func _on_play_button_down() -> void:
	TransitionScene.transitionToScene("res://Nodes/Scenes/overworld.tscn")

func _on_exit_button_down() -> void:
	get_tree().quit()

func setOptionMenu():
	inOptions = !inOptions

	$MenuCanvas.visible = !inOptions
	$Options.visible = inOptions
	
	if inOptions:
		$Options.setFocus()
	else:
		$MenuCanvas/Options/Play.grab_focus()


func _on_btn_focus_entered() -> void:
	$Audio/SelectSfx.play()

func _on_btn_pressed() -> void:
	$Audio/ConfirmSfx.play()
