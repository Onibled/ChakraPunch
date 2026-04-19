extends Node2D

@export var health_component: Node
@export var offset := Vector2(0, -40)

@onready var bar: ProgressBar = $ProgressBar

func _ready():
	if health_component == null:
		push_error("HealthBar: manca health_component")
		return
	
	# inizializza valori
	bar.max_value = health_component.max_health
	bar.value = health_component.health
	
	# connessioni
	health_component.health_changed.connect(_on_health_changed)
	health_component.died.connect(_on_died)
	
	update_visibility()

func _process(_delta):
	# segue il parent (enemy)
	if get_parent():
		global_position = get_parent().global_position + offset

# -------------------------------------------------
# ❤️ UPDATE
# -------------------------------------------------

func _on_health_changed(value):
	bar.value = value
	update_color()
	update_visibility()

func _on_died():
	hide()

# -------------------------------------------------
# 👁️ VISIBILITÀ
# -------------------------------------------------

func update_visibility():
	# visibile solo se danneggiato
	if health_component.health < health_component.max_health:
		show()
	else:
		hide()
	return
	
func update_color():
	var percent = bar.value / bar.max_value
	
	# da verde → rosso
	var color = Color(
		1.0 - percent,  # più vita → meno rosso
		percent,        # più vita → più verde
		0.2
	)
	
	bar.modulate = color
	return
