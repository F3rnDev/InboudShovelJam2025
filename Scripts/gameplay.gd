extends Node2D
#do things like win game and game over stuff
#call signals on other objects
var gameOver = false

func _process(delta: float) -> void:
	if gameOver and Input.is_action_just_pressed("Reset"):
		get_tree().reload_current_scene()

func _on_player_entered_ufo() -> void:
	$GameCamera.changePlayer(1)

func _on_player_player_dead() -> void:
	gameOver = true

func _on_player_hit() -> void:
	$GameCamera.shakeCamera()
