extends Control

var paused = false
var inOptions = false

func _ready() -> void:
	self.visible = false
	$Pause.visible = false
	$Options.visible = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Cancel") and !inOptions:
		pauseGame()

func pauseGame():
	paused = !paused
	
	get_tree().paused = paused
	self.visible = paused
	$Pause.visible = paused
	
	if paused:
		$Pause/VBoxContainer/Resume.grab_focus()

func _on_resume_button_down() -> void:
	pauseGame()

func _on_overworld_button_down() -> void:
	pauseGame()
	TransitionScene.transitionToScene("res://Nodes/Scenes/Menu/overworld.tscn")

func toggleOptions():
	inOptions = !inOptions
	
	$Pause.visible = !inOptions
	$Options.visible = inOptions
	
	if !inOptions:
		$Pause/VBoxContainer/Resume.grab_focus()
	else:
		$"Options/VBoxContainer/ScreenSection/Fullscreen check".grab_focus()


func _on_focus_entered() -> void:
	$Audio/SelectSfx.play()

func _on_button_down() -> void:
	$Audio/ConfirmSfx.play()
