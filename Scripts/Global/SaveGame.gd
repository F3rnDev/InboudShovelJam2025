extends Node

#Configurations and their defaults
@export var configDict = {
	"fullscreen" = false,
	"masterVolume" = 100.0,
	"musicVolume" = 100.0,
	"sfxVolume" = 100.0
}

func _ready() -> void:
	getConfigData()
	loadConfig()

func getConfigData():
	if !FileAccess.file_exists("user://configFile.config"):
		return
	
	var save_file = FileAccess.open("user://configFile.config", FileAccess.READ)
	var json_string = save_file.get_as_text()
	
	configDict = JSON.parse_string(json_string)

func loadConfig(configData = null):
	var windowType = DisplayServer.WINDOW_MODE_WINDOWED
	if configDict["fullscreen"]:
		windowType = DisplayServer.WINDOW_MODE_FULLSCREEN
	
	DisplayServer.window_set_mode(windowType)
	
	#SetAudio

func setConfigData(newConfig):
	configDict = newConfig
	var save_file = FileAccess.open("user://configFile.config", FileAccess.WRITE)
	var json_string = JSON.stringify(configDict)
	
	save_file.store_line(json_string)
	save_file.close()
