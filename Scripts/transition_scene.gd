extends CanvasLayer

signal fadeInOver
signal fadeOutOver

func transitionToScene(path):
	if $"Transition animation".is_playing():
		await $"Transition animation".animation_finished
	
	visible = true
	$"Transition animation".play("fadeIn")
	await $"Transition animation".animation_finished
	
	get_tree().change_scene_to_file(path)
	
	$"Transition animation".play("fadeOut")
	await $"Transition animation".animation_finished
	visible = false

func transitionToSameScene():
	if $"Transition animation".is_playing():
		await $"Transition animation".animation_finished
	
	visible = true
	$"Transition animation".play("fadeIn")
	await $"Transition animation".animation_finished
	
	get_tree().reload_current_scene()
	
	$"Transition animation".play("fadeOut")
	await $"Transition animation".animation_finished
	visible = false

func transitionInsideScene():
	if $"Transition animation".is_playing():
		await $"Transition animation".animation_finished
	
	visible = true
	$"Transition animation".play("fadeIn")
	await $"Transition animation".animation_finished
	
	fadeInOver.emit()
	
	$"Transition animation".play("fadeOut")
	await $"Transition animation".animation_finished
	fadeOutOver.emit()
	visible = false
