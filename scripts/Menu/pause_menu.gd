extends CanvasLayer

@onready var center_container: CenterContainer = $CenterContainer
@onready var resume_btn: Button = $CenterContainer/VBoxContainer/Resume
@onready var settings_btn = $CenterContainer/VBoxContainer/Settings
@onready var menu_btn = $CenterContainer/VBoxContainer/MainMenu

func _ready():
	hide_menu()
	resume_btn.pressed.connect(_on_resume)
	settings_btn.pressed.connect(_on_settings)
	menu_btn.pressed.connect(_on_menu)

	resume_btn.grab_focus()

func _unhandled_input(delta):
	if Input.is_action_just_pressed("pause"):
		toggle_pause()

# -------------------------------------------------
# 🎮 TOGGLE PAUSE
# -------------------------------------------------

func toggle_pause():
	if get_tree().paused:
		resume()
	else:
		pause()
	return

func pause():
	get_tree().paused = true
	show_menu()
	
	await get_tree().process_frame
	resume_btn.grab_focus()
	return

func resume():
	get_tree().paused = false
	hide_menu()
	return

# -------------------------------------------------
# 🎛️ UI ACTIONS
# -------------------------------------------------

func _on_resume():
	resume()

func _on_menu():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	return

func _on_settings():
	print("Settings TODO")
	return

func _on_load():
	print("Load TODO")
	return

# -------------------------------------------------
# 👁 UI CONTROL
# -------------------------------------------------

func show_menu():
	center_container.visible = true
	
	await get_tree().process_frame
	resume_btn.grab_focus()
	return

func hide_menu():
	center_container.visible = false
	return
