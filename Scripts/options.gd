extends CanvasLayer
#FulscreenOption
@onready var fullscreen = $"VBoxContainer/ScreenSection/Fullscreen check"
#Master Audio
@onready var MasterSliderLabel = $VBoxContainer/AudioSection/MasterSlider/Label
@onready var MasterSlider = $VBoxContainer/AudioSection/MasterSlider/HSlider
#Music Audio
@onready var MusicSliderLabel = $VBoxContainer/AudioSection/MusicSlider/Label
@onready var MusicSlider = $VBoxContainer/AudioSection/MusicSlider/HSlider
#SFX Audio
@onready var SfxSliderLabel = $VBoxContainer/AudioSection/SFXSlider/Label
@onready var SfxSlider = $VBoxContainer/AudioSection/SFXSlider/HSlider

signal applyConfig

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	loadPlayerConfig()
	setSliderLabels()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Cancel") and self.visible:
		applyOptions()

func setFocus():
	$"VBoxContainer/ScreenSection/Fullscreen check".grab_focus()

func loadPlayerConfig():
	fullscreen.button_pressed = PlayerData.configDict["fullscreen"]
	MasterSlider.value = PlayerData.configDict["masterVolume"]
	MusicSlider.value = PlayerData.configDict["musicVolume"]
	SfxSlider.value = PlayerData.configDict["sfxVolume"]

func setSliderLabels():
	MasterSliderLabel.text = str(int(MasterSlider.value*100)) + "%"
	MusicSliderLabel.text = str(int(MusicSlider.value*100)) + "%"
	SfxSliderLabel.text = str(int(SfxSlider.value*100)) + "%"

func _on_masterSlider_value_changed(value: float) -> void:
	MasterSliderLabel.text = str(int(value*100)) + "%"
	
	var audio = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(audio, linear_to_db(value))

func _on_musicSlider_value_changed(value: float) -> void:
	MusicSliderLabel.text = str(int(value*100)) + "%"
	
	var audio = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(audio, linear_to_db(value))

func _on_SfxSlider_value_changed(value: float) -> void:
	SfxSliderLabel.text = str(int(value*100)) + "%"
	
	var audio = AudioServer.get_bus_index("Sound Effects")
	AudioServer.set_bus_volume_db(audio, linear_to_db(value))
	
	$Audio/SelectSfx.play()

func _on_fullscreen_check_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_apply_button_down() -> void:
	applyOptions()

func applyOptions():
	applyConfig.emit()
	var newOptions = {
		"fullscreen" = fullscreen.button_pressed,
		"masterVolume" = MasterSlider.value,
		"musicVolume" = MusicSlider.value,
		"sfxVolume" = SfxSlider.value
	}
	
	PlayerData.setConfigData(newOptions)
	
	$Audio/ConfirmSfx.play()

func _on_focus_entered() -> void:
	$Audio/SelectSfx.play()
