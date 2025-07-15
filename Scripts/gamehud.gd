extends CanvasLayer

func updateHealth(curHealth):
	var lifes = $Control/VBoxContainer/LifeHolder/Life/LifeFull
	
	for lifeID in lifes.get_child_count():
		var life = lifes.get_child(lifeID)
		
		if lifeID+1 > curHealth:
			life.queue_free()

func setCapturedEnemies(enemies):
	$Control/VBoxContainer/HBoxContainer/Label.text = "x " + str(enemies)
