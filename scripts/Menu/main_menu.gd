extends Control

@onready var btn_new = $CenterContainer/VBoxContainer/NewGame
@onready var btn_continue = $CenterContainer/VBoxContainer/Continue
@onready var btn_settings = $CenterContainer/VBoxContainer/Settings
@onready var btn_credits = $CenterContainer/VBoxContainer/Credits
@onready var btn_exit = $CenterContainer/VBoxContainer/Exit

func _ready():
	btn_new.pressed.connect(_on_new_game)
	btn_continue.pressed.connect(_on_continue)
	btn_settings.pressed.connect(_on_settings)
	btn_credits.pressed.connect(_on_credits)
	btn_exit.pressed.connect(_on_exit)
	
	btn_new.grab_focus()

	check_save()
	return

# -------------------------------------------------
# 🎮 AZIONI
# -------------------------------------------------

func _on_new_game():
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func _on_continue():
	load_game()

func _on_settings():
	get_tree().change_scene_to_file("res://scenes/Menu/settings.tscn")

func _on_credits():
	get_tree().change_scene_to_file("res://scenes/Credits.tscn")

func _on_exit():
	get_tree().quit()

# -------------------------------------------------
# 💾 SAVE CHECK
# -------------------------------------------------

func check_save():
	if not FileAccess.file_exists("user://save.dat"):
		btn_continue.disabled = true

func load_game():
	if not FileAccess.file_exists("user://save.dat"):
		return
	
	# esempio semplice
	get_tree().change_scene_to_file("res://scenes/Game.tscn")
