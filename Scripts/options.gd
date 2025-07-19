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

func setFocus():
	$"VBoxContainer/ScreenSection/Fullscreen check".grab_focus()

func loadPlayerConfig():
	fullscreen.button_pressed = PlayerData.configDict["fullscreen"]
	MasterSlider.value = PlayerData.configDict["masterVolume"]
	MusicSlider.value = PlayerData.configDict["musicVolume"]
	SfxSlider.value = PlayerData.configDict["sfxVolume"]

func setSliderLabels():
	MasterSliderLabel.text = str(int(MasterSlider.value)) + "%"
	MusicSliderLabel.text = str(int(MusicSlider.value)) + "%"
	SfxSliderLabel.text = str(int(SfxSlider.value)) + "%"

func _on_masterSlider_value_changed(value: float) -> void:
	MasterSliderLabel.text = str(int(value)) + "%"

func _on_musicSlider_value_changed(value: float) -> void:
	MusicSliderLabel.text = str(int(value)) + "%"

func _on_SfxSlider_value_changed(value: float) -> void:
	SfxSliderLabel.text = str(int(value)) + "%"

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
