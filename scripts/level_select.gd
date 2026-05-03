extends Control

@onready var container = $VBoxContainer

var levels := []
var selected_index := 0

# ---------------------------------------------------------

func _ready():
	load_levels()
	create_buttons()
	update_selection()


# ---------------------------------------------------------

func load_levels():
	var dir = DirAccess.open("res://scenes/levels/")
	
	if dir == null:
		push_error("Cartella livelli non trovata")
		return
	
	dir.list_dir_begin()
	
	var file = dir.get_next()
	while file != "":
		if file.ends_with(".tscn"):
			levels.append(file)
		file = dir.get_next()
	
	dir.list_dir_end()
	levels.sort()

# ---------------------------------------------------------

func create_buttons():
	for i in levels.size():
		var btn = Button.new()
		
		btn.text = levels[i].replace(".tscn", "").capitalize()
		btn.focus_mode = Control.FOCUS_ALL
		
		btn.pressed.connect(_on_level_selected.bind(i))
		
		container.add_child(btn)
	container.get_child(0).grab_focus()

# ---------------------------------------------------------

func _on_level_selected(index):
	var path = "res://scenes/levels/" + levels[index]
	get_tree().change_scene_to_file(path)
	
func update_selection():
	for i in container.get_child_count():
		var btn = container.get_child(i)
		
		if i == selected_index:
			btn.grab_focus()
