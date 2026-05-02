extends Control

const SETTINGS_PATH = "user://settings.cfg"

@onready var resolution_option = $CenterContainer/VBoxContainer/Resolution/OptionButton
@onready var fullscreen_toggle = $CenterContainer/VBoxContainer/Fullscreen/CheckBox
@onready var vsync_toggle = $CenterContainer/VBoxContainer/VSync/CheckBox
@onready var volume_slider = $CenterContainer/VBoxContainer/Volume/HSlider
@onready var back_button = $CenterContainer/VBoxContainer/Back

var resolutions = [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440)
]

func _ready():
	setup_resolutions()
	load_settings()
	
	resolution_option.item_selected.connect(_on_resolution_selected)
	fullscreen_toggle.toggled.connect(_on_fullscreen_toggled)
	vsync_toggle.toggled.connect(_on_vsync_toggled)
	volume_slider.value_changed.connect(_on_volume_changed)
	back_button.pressed.connect(_on_back_pressed)
	return
	
func save_settings():
	var config = ConfigFile.new()
	
	config.set_value("video", "resolution", resolution_option.selected)
	config.set_value("video", "fullscreen", fullscreen_toggle.button_pressed)
	config.set_value("video", "vsync", vsync_toggle.button_pressed)
	config.set_value("audio", "volume", volume_slider.value)
	
	config.save(SETTINGS_PATH)
	return

func load_settings():
	var config = ConfigFile.new()
	
	if config.load(SETTINGS_PATH) != OK:
		return
	
	var res_index = config.get_value("video", "resolution", 0)
	var fullscreen = config.get_value("video", "fullscreen", false)
	var vsync = config.get_value("video", "vsync", true)
	var volume = config.get_value("audio", "volume", 1.0)
	
	resolution_option.select(res_index)
	fullscreen_toggle.button_pressed = fullscreen
	vsync_toggle.button_pressed = vsync
	volume_slider.value = volume
	
	_on_resolution_selected(res_index)
	_on_fullscreen_toggled(fullscreen)
	_on_vsync_toggled(vsync)
	_on_volume_changed(volume)
	return

# RISOLUZIONE
func setup_resolutions():
	for i in resolutions.size():
		var r = resolutions[i]
		resolution_option.add_item(str(r.x) + "x" + str(r.y), i)
	return

func _on_resolution_selected(index):
	var res = resolutions[index]
	DisplayServer.window_set_size(res)
	save_settings()
	return

# FULLSCREEN
func _on_fullscreen_toggled(enabled):
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	save_settings()
	return

# VSYNC
func _on_vsync_toggled(enabled):
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if enabled else DisplayServer.VSYNC_DISABLED
	)
	save_settings()
	
# VOLUME
func _on_volume_changed(value):
	# value 0 → 1
	AudioServer.set_bus_volume_db(0, linear_to_db(value))
	save_settings()
	return
	
# BACK
func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/Menu/main_menu.tscn")
