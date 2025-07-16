extends CanvasLayer

func transitionToScene(path):
	visible = true
	$"Transition animation".play("fadeIn")
	await $"Transition animation".animation_finished
	
	get_tree().change_scene_to_file(path)
	
	$"Transition animation".play("fadeOut")
	await $"Transition animation".animation_finished
	visible = false

func transitionToSameScene():
	visible = true
	$"Transition animation".play("fadeIn")
	await $"Transition animation".animation_finished
	
	get_tree().reload_current_scene()
	
	$"Transition animation".play("fadeOut")
	await $"Transition animation".animation_finished
	visible = false
