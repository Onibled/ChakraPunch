extends CharacterBody2D

# -------------------------------------------------
# ⚙️ BASE
# -------------------------------------------------

@export var speed := 400.0
@export var lifetime := 3.0

var direction := Vector2.RIGHT

# -------------------------------------------------
# 🔁 FEATURE TOGGLES
# -------------------------------------------------

@export var use_boomerang := false
@export var use_zigzag := false
@export var multi_hit := false
@export var apply_status := false

# -------------------------------------------------
# 🧭 DIREZIONE
# -------------------------------------------------

@export var use_custom_direction := false
@export var custom_direction := Vector2.RIGHT

# -------------------------------------------------
# 🌀 ZIGZAG
# -------------------------------------------------

@export var zigzag_amplitude := 20.0
@export var zigzag_frequency := 10.0
var zigzag_time := 0.0

# -------------------------------------------------
# 🔄 BOOMERANG
# -------------------------------------------------

var returning := false
var max_distance := 300.0
var start_position := Vector2.ZERO

# -------------------------------------------------
# 💥 HIT
# -------------------------------------------------

@export var damage := 20
@export var knockback := Vector2(300, -100)

var hit_targets := []

# -------------------------------------------------
# 🔄 READY
# -------------------------------------------------

func _ready():
	start_position = global_position
	
	if use_custom_direction:
		direction = custom_direction.normalized()
	else:
		direction = direction.normalized()
	
	velocity = direction * speed
	
	await get_tree().create_timer(lifetime).timeout
	queue_free()

# -------------------------------------------------
# 🔄 PHYSICS
# -------------------------------------------------

func _physics_process(delta):
	
	var move_dir = direction
	
	# ----------------------------------------
	# 🌀 ZIGZAG
	# ----------------------------------------
	
	if use_zigzag:
		zigzag_time += delta
		
		var perpendicular = Vector2(-direction.y, direction.x)
		var offset = perpendicular * sin(zigzag_time * zigzag_frequency) * zigzag_amplitude
		
		move_dir = direction + offset.normalized() * 0.3
	
	# ----------------------------------------
	# 🔄 BOOMERANG
	# ----------------------------------------
	
	if use_boomerang and not returning:
		if global_position.distance_to(start_position) > max_distance:
			returning = true
	
	if returning and owner:
		move_dir = (owner.global_position - global_position).normalized()
	
	# ----------------------------------------
	# 🚀 MOVIMENTO
	# ----------------------------------------
	
	velocity = move_dir.normalized() * speed
	move_and_slide()
	
	# ----------------------------------------
	# 🎯 ROTAZIONE VISIVA
	# ----------------------------------------
	
	rotation = velocity.angle()
	
	# 💥 collisione con muro
	if is_on_wall():
		queue_free()

# -------------------------------------------------
# 💥 HIT SYSTEM
# -------------------------------------------------

func _on_hitbox_body_entered(body):
	
	if body == owner:
		return
	
	if not body.has_method("apply_knockback"):
		return
	
	# evita hit multipli se single-hit
	if not multi_hit and hit_targets.size() > 0:
		return
	
	# evita colpire lo stesso target più volte
	if body in hit_targets:
		return
	
	hit_targets.append(body)
	
	body.apply_knockback(damage, knockback * Vector2(sign(direction.x), 1), {})
	
	# ----------------------------------------
	# 🌡️ STATUS EFFECT
	# ----------------------------------------
	
	if apply_status and body.has_method("apply_status"):
		body.apply_status("burn", 2.0) # esempio
	
	# ----------------------------------------
	# ❌ SINGLE HIT → DISTRUGGI
	# ----------------------------------------
	
	if not multi_hit:
		queue_free()
