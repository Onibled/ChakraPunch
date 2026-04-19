extends CharacterBody2D

# =========================================================
# 🚀 SETTINGS
# =========================================================

@export var speed: float = 120.0
@export var active: bool = true

enum LoopMode { STOP, LOOP, PINGPONG }
@export var loop_mode: LoopMode = LoopMode.PINGPONG

@export var reach_threshold: float = 5.0

# 👉 PUNTI GLOBALI
@export var points: Array[Vector2] = []

# debug
@export var draw_path: bool = true

# =========================================================
# 🔄 INTERNAL
# =========================================================

var current_index: int = 0
var direction: int = 1

var last_position: Vector2

# =========================================================
# 🔄 READY
# =========================================================

func _ready():
	last_position = global_position
	
	if points.is_empty():
		push_error("MovingPlatform: nessun punto impostato")
		set_physics_process(false)
		return

# =========================================================
# 🔄 PHYSICS
# =========================================================

func _physics_process(delta):
	if not active:
		return
	
	if points.is_empty():
		return
	
	# sicurezza contro out-of-bounds
	current_index = clamp(current_index, 0, points.size() - 1)
	
	var target_pos: Vector2 = points[current_index]
	
	var move_vec = target_pos - global_position
	var distance = move_vec.length()
	
	# -------------------------------------------------
	# 🎯 RAGGIUNTO PUNTO
	# -------------------------------------------------
	
	if distance < reach_threshold:
		advance_target()
		return
	
	# -------------------------------------------------
	# 🚀 MOVIMENTO
	# -------------------------------------------------
	
	var dir = move_vec.normalized()
	velocity = dir * speed
	
	move_and_slide()
	
	# -------------------------------------------------
	# 🧍 TRASPORTO PLAYER
	# -------------------------------------------------
	
	var delta_movement = global_position - last_position
	move_passengers(delta_movement)
	
	last_position = global_position

# =========================================================
# 🧍 PLAYER TRANSPORT
# =========================================================

func move_passengers(delta_movement: Vector2):
	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		var body = col.get_collider()
		
		if body is CharacterBody2D:
			# controlla che sia sopra (normale verso l'alto)
			if col.get_normal().y < -0.7:
				body.global_position += delta_movement

# =========================================================
# 🔁 TARGET LOGIC
# =========================================================

func advance_target():
	match loop_mode:
		
		LoopMode.STOP:
			if current_index < points.size() - 1:
				current_index += 1
			else:
				active = false
		
		LoopMode.LOOP:
			current_index += 1
			if current_index >= points.size():
				current_index = 0
		
		LoopMode.PINGPONG:
			current_index += direction
			
			if current_index >= points.size():
				current_index = points.size() - 2
				direction = -1
			
			elif current_index < 0:
				current_index = 1
				direction = 1

# =========================================================
# 🎛️ CONTROLLO
# =========================================================

func activate():
	active = true
	
	if current_index >= points.size():
		current_index = 0

func deactivate():
	active = false
	velocity = Vector2.ZERO

# =========================================================
# 🎨 DEBUG DRAW
# =========================================================

func _process(_delta):
	if draw_path:
		queue_redraw()

func _draw():
	if not draw_path:
		return
	
	if points.size() < 1:
		return
	
	# punti
	for p in points:
		draw_circle(to_local(p), 5, Color.GREEN)
	
	# linee tratteggiate
	for i in range(points.size() - 1):
		draw_dashed_line(
			to_local(points[i]),
			to_local(points[i + 1]),
			Color.CYAN,
			2.0,
			10.0
		)
