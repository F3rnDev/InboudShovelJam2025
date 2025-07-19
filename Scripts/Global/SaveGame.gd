extends Node

#Configurations and their defaults
var configDict = {
	"fullscreen" = false,
	"masterVolume" = 100.0,
	"musicVolume" = 100.0,
	"sfxVolume" = 100.0
}

#Stage
var stages = {}

func _ready() -> void:
	getConfigData()
	loadConfig()
	
	

#CONFIGURATION
func getConfigData():
	if !FileAccess.file_exists("user://configFile.config"):
		return
	
	var save_file = FileAccess.open("user://config.json", FileAccess.READ)
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
	var save_file = FileAccess.open("user://config.json", FileAccess.WRITE)
	var json_string = JSON.stringify(configDict)
	
	save_file.store_line(json_string)
	save_file.close()

#STAGE
func getStageData(path):
	if !FileAccess.file_exists("user://stages.save"):
		return
	
	var save_file = FileAccess.open("user://stages.save", FileAccess.READ)
	var json_string = save_file.get_as_text()
	
	stages = JSON.parse_string(json_string)
	
	if stages.has(path):
		return stages[path]
	
	return null

func setStageData(data):
	stages[data["stagePath"]] = data
	var save_file = FileAccess.open("user://stages.save", FileAccess.WRITE)
	var json_string = JSON.stringify(stages)
	
	save_file.store_line(json_string)
	save_file.close()
