extends CanvasLayer

@onready var center_container: CenterContainer = $CenterContainer

func _ready():
	hide_menu()

func _process(delta):
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

func pause():
	get_tree().paused = true
	show_menu()

func resume():
	get_tree().paused = false
	hide_menu()

# -------------------------------------------------
# 🎛️ UI ACTIONS
# -------------------------------------------------

func _on_resume_pressed():
	resume()

func _on_quit_pressed():
	get_tree().quit()

func _on_settings_pressed():
	print("Settings TODO")

func _on_load_pressed():
	print("Load TODO")

# -------------------------------------------------
# 👁 UI CONTROL
# -------------------------------------------------

func show_menu():
	center_container.visible = true

func hide_menu():
	center_container.visible = false
