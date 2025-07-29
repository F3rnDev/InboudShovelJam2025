extends ParallaxBackground

@export var scroolSpeed = 30;

func _process(delta: float) -> void:
	pass
	#for layerID in get_child_count():
		#get_child(layerID).motion_offset.x -= scroolSpeed * layerID * delta;
