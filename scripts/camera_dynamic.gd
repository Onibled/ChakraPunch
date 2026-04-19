extends Camera2D

# =========================================================
# 📷 SETTINGS
# =========================================================

@export var follow_speed := 8.0
@export var max_speed := 1200.0

@export var look_ahead_distance := 60.0
@export var look_ahead_speed := 4.0

@export var deadzone := Vector2(16, 12)

var target: CharacterBody2D = null

# smoothing
var velocity := Vector2.ZERO

# look ahead
var look_ahead := Vector2.ZERO

# lock system
var is_locked := false
var locked_position := Vector2.ZERO

# =========================================================
# 📳 SHAKE
# =========================================================

var shake_strength := 0.0
var shake_decay := 6.0

# =========================================================
# 🔍 ZOOM
# =========================================================

var base_zoom := Vector2.ONE

# =========================================================
# 🔄 READY
# =========================================================

func _ready():
	add_to_group("camera")
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	target = get_tree().get_first_node_in_group("player")
	snap_to_target()
	velocity = Vector2.ZERO
	return

# =========================================================
# 🔄 PROCESS
# =========================================================

func _process(delta):
	update_follow(delta)
	update_shake(delta)

# =========================================================
# 🎯 FOLLOW SYSTEM (STABILE)
# =========================================================

func update_follow(delta):
	if target == null:
		return
	
	var desired_position: Vector2
	
	# -------------------------
	# LOCK
	# -------------------------
	
	if is_locked:
		desired_position = locked_position
	else:
		# -------------------------
		# LOOK AHEAD (smooth)
		# -------------------------
		
		var dir = sign(target.velocity.x)
		var target_look = Vector2(dir * look_ahead_distance, 0)
		look_ahead = look_ahead.lerp(target_look, look_ahead_speed * delta)
		
		desired_position = target.global_position + look_ahead
	
	# -------------------------
	# DEADZONE
	# -------------------------
	
	var diff = desired_position - global_position
	
	if abs(diff.x) < deadzone.x:
		diff.x = 0
	if abs(diff.y) < deadzone.y:
		diff.y = 0
	
	# -------------------------
	# SMOOTH (NO OSCILLAZIONE)
	# -------------------------
	
	var target_velocity = diff * follow_speed
	
	# smorzamento vero
	velocity = velocity.lerp(target_velocity, 0.15)
	
	# clamp sicurezza
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	
	global_position += velocity * delta

# =========================================================
# 🔒 LOCK SYSTEM
# =========================================================

func lock_to_position(pos: Vector2):
	is_locked = true
	locked_position = pos

func unlock():
	is_locked = false

# =========================================================
# 📳 SHAKE SYSTEM
# =========================================================

func update_shake(delta):
	if shake_strength > 0:
		offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
		
		shake_strength = lerp(shake_strength, 0.0, shake_decay * delta)
	else:
		offset = Vector2.ZERO

func shake(amount: float):
	shake_strength = max(shake_strength, amount)

# =========================================================
# 🔍 IMPACT ZOOM
# =========================================================

func impact_zoom():
	zoom = Vector2(0.9, 0.9)
	await get_tree().create_timer(0.05).timeout
	zoom = base_zoom

# =========================================================
# 🧠 SNAP (utile)
# =========================================================

func snap_to_target():
	if target:
		global_position = target.global_position
