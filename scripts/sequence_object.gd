extends Node2D

# -------------------------------------------------
# ⚙️ CONFIG
# -------------------------------------------------

@export var sequence_length := 4

# sequenza richiesta (configurabile da editor)
@export var sequence := [
	"interact",
	"light_attack",
	"heavy_attack",
	"jump"
]

@export var spacing := 24.0
@export var sprite_scale := Vector2(0.5, 0.5)

# -------------------------------------------------
# 🎨 MAPPA SEGNI → TEXTURE
# -------------------------------------------------

@export var textures := {
	"interact": preload("res://sprites/circle.png"),
	"light_attack": preload("res://sprites/square_mini.png"),
	"heavy_attack": preload("res://sprites/triangle.png"),
	"jump": preload("res://sprites/cross.png")
}

@export var textures_black := {
	"interact": preload("res://sprites/circle_b.png"),
	"light_attack": preload("res://sprites/square_mini_b.png"),
	"heavy_attack": preload("res://sprites/triangle_b.png"),
	"jump": preload("res://sprites/cross_b.png")
}

# -------------------------------------------------
# 📊 STATO
# -------------------------------------------------

var sprites: Array[Sprite2D] = []
var current_index := 0

var player_ref: Player = null
var was_meditating := false

@export var targets: Array[Activatable] = []

# -------------------------------------------------
# 🔄 READY
# -------------------------------------------------

func _ready():
	_build_visuals()

# -------------------------------------------------
# 🎨 CREA UI DINAMICA
# -------------------------------------------------

func _build_visuals():
	for i in range(sequence_length):
		var s := Sprite2D.new()
		add_child(s)

		s.position = Vector2(i * spacing, 0)
		s.scale = sprite_scale
		s.texture = textures_black[sequence[i]]
		#s.modulate.a = 0.2

		sprites.append(s)

# -------------------------------------------------
# 🔄 UPDATE
# -------------------------------------------------

func _process(delta):
	_find_player()

	if player_ref == null:
		return

	# ❌ NON è in meditazione → reset automatico
	if not player_ref.meditating:
		if was_meditating:
			_reset()
		was_meditating = false
		return

	was_meditating = true

	# 🎮 ricezione input SOLO in meditazione
	_poll_inputs()

# -------------------------------------------------
# 👤 PLAYER FIND
# -------------------------------------------------

func _find_player():
	if player_ref != null:
		return

	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_ref = players[0]

# -------------------------------------------------
# 🎮 INPUT LOGICO
# -------------------------------------------------

func _poll_inputs():
	if Input.is_action_just_pressed("light_attack"):
		_register("light_attack")

	if Input.is_action_just_pressed("heavy_attack"):
		_register("heavy_attack")

	if Input.is_action_just_pressed("interact"):
		_register("interact")

	if Input.is_action_just_pressed("jump"):
		_register("jump")

# -------------------------------------------------
# 🧠 LOGICA SEQUENZA
# -------------------------------------------------

func _register(action: String):
	if current_index >= sequence_length:
		return

	var expected = sequence[current_index]

	if action == expected:
		_correct(action)
	else:
		_wrong()

# -------------------------------------------------
# ✔️ CORRETTO
# -------------------------------------------------

func _correct(action: String):
	sprites[current_index].texture = textures[action]
	#sprites[current_index].modulate = Color(1, 1, 1, 1)

	current_index += 1

	if current_index >= sequence_length:
		_completed()

# -------------------------------------------------
# ❌ ERRORE
# -------------------------------------------------

func _wrong():
	_reset()

# -------------------------------------------------
# 🏁 COMPLETATO
# -------------------------------------------------

func _completed():
	print("Sequenza completata!")
	activate_targets()
	_reset()

# -------------------------------------------------
# 🔄 RESET
# -------------------------------------------------

func _reset():
	current_index = 0

	for s in sprites:
		s.texture = textures_black[sequence[current_index]]
		#s.modulate = Color(1, 1, 1, 0.2)
		current_index += 1
	current_index = 0
	return
	
func activate_targets():
	for target in targets:
		if target == null:
			continue

		target.activate()
	return
	

# -------------------------------------------------
# 🎨 DEBUG DRAW
# -------------------------------------------------

func _draw():
	for target in targets:
		if target == null:
			continue

		var local_target_pos = to_local(target.global_position)
		draw_line(Vector2.ZERO, local_target_pos, Color(0.6, 0.2, 1.0), 2.0)
