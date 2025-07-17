extends CanvasLayer

signal captureThemSignal

func setStageText(stageName):
	$Control/CurrentStage.text = "Current Stage\n- " + stageName + " -"

func setGameOverText():
	$Control/GameOverText/AnimationPlayer.play("blink")

func setGameWinText():
	$Control/WinGameText/AnimationPlayer.play("blink")

func setCaptureThemText():
	$"Control/Capture Them/AnimationPlayer".play("captureAll")

func _on_capture_animation_finished(anim_name: StringName) -> void:
	captureThemSignal.emit()

func updateHealth(curHealth):
	var lifes = $Control/VBoxContainer/LifeHolder/Life/LifeFull
	
	for lifeID in lifes.get_child_count():
		var life = lifes.get_child(lifeID)
		
		if lifeID+1 > curHealth:
			life.queue_free()

func setCapturedEnemies(enemies):
	$Control/VBoxContainer/HBoxContainer/Label.text = "x " + str(enemies)
