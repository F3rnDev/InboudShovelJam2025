extends CanvasLayer

@export var sweepOn:AudioStream
@export var sweepOff:AudioStream

var sceneToChange = null

func transitionToScene(path):
	sceneToChange = path
	fadeIn()

func fadeIn():
	if $"Transition animation".is_playing():
		return
	
	visible = true
	$"Transition animation".play("fadeIn")
	$Sweep.stream = sweepOn
	$Sweep.play()

func fadeOut():
	get_tree().change_scene_to_file(sceneToChange)
	
	$"Transition animation".play("fadeOut")
	$Sweep.stream = sweepOff
	$Sweep.play()

func _on_transition_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fadeIn":
		fadeOut()
	elif anim_name == "fadeOut":
		sceneToChange = null
		visible = false
