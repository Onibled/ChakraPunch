extends Node2D
class_name Lever

@export var targets: Array[Activatable] = []
@export var toggle_mode: bool = true   # true = toggle, false = solo activate

var player_in_range: bool = false

# -------------------------------------------------
# 🔄 READY
# -------------------------------------------------

func _ready():
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)

# -------------------------------------------------
# 🎮 INPUT
# -------------------------------------------------

func _process(delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		activate_targets()
		
	if player_in_range:
		modulate = Color(1,1,1)
	else:
		modulate = Color(0.7,0.7,0.7)

	queue_redraw()

# -------------------------------------------------
# 🔘 ATTIVAZIONE
# -------------------------------------------------

func activate_targets():
	for target in targets:
		if target == null:
			continue

		if toggle_mode:
			target.toggle()
		else:
			target.activate()

# -------------------------------------------------
# 🧍 RANGE CHECK
# -------------------------------------------------

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false

# -------------------------------------------------
# 🎨 DEBUG DRAW
# -------------------------------------------------

func _draw():
	for target in targets:
		if target == null:
			continue

		var local_target_pos = to_local(target.global_position)
		draw_line(Vector2.ZERO, local_target_pos, Color(0.6, 0.2, 1.0), 2.0)
