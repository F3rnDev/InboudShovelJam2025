extends CanvasLayer

signal fadeInOver
signal fadeOutOver

@export var sweepOn:AudioStream
@export var sweepOff:AudioStream

func transitionToScene(path):
	if $"Transition animation".is_playing():
		await $"Transition animation".animation_finished
	
	visible = true
	$"Transition animation".play("fadeIn")
	$Sweep.stream = sweepOn
	$Sweep.play()
	await $"Transition animation".animation_finished
	
	get_tree().change_scene_to_file(path)
	
	$"Transition animation".play("fadeOut")
	$Sweep.stream = sweepOff
	$Sweep.play()
	await $"Transition animation".animation_finished
	visible = false

func transitionToSameScene():
	if $"Transition animation".is_playing():
		await $"Transition animation".animation_finished
	
	visible = true
	$"Transition animation".play("fadeIn")
	$Sweep.stream = sweepOn
	$Sweep.play()
	await $"Transition animation".animation_finished
	
	get_tree().reload_current_scene()
	
	$"Transition animation".play("fadeOut")
	$Sweep.stream = sweepOff
	$Sweep.play()
	await $"Transition animation".animation_finished
	visible = false

func transitionInsideScene():
	if $"Transition animation".is_playing():
		await $"Transition animation".animation_finished
	
	visible = true
	$"Transition animation".play("fadeIn")
	$Sweep.stream = sweepOn
	$Sweep.play()
	await $"Transition animation".animation_finished
	
	fadeInOver.emit()
	
	$"Transition animation".play("fadeOut")
	$Sweep.stream = sweepOff
	$Sweep.play()
	await $"Transition animation".animation_finished
	fadeOutOver.emit()
	visible = false
