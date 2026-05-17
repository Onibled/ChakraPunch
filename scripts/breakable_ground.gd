extends StaticBody2D

# -------------------------------------------------
# ⚙️ SETTINGS
# -------------------------------------------------

@export var max_light_hits := 3
@export var max_heavy_hits := 1

@export var only_heavy := false      # rompe SOLO con heavy
@export var only_light := false      # rompe SOLO con light

@export var break_on_zero := true    # si rompe quando arriva a 0

# feedback
@export var flash_on_hit := true
@export var shake_on_hit := true

# -------------------------------------------------
# 📊 STATE
# -------------------------------------------------

var light_hits_left := 0
var heavy_hits_left := 0

var is_broken := false

# -------------------------------------------------
# 🔗 REFERENCES
# -------------------------------------------------

@onready var sprite: Node2D = $Sprite2D
@onready var collision: CollisionShape2D = $Hurtbox/CollisionShape2D

# opzionale
@onready var anim: AnimationPlayer = $AnimationPlayer

# -------------------------------------------------
# 🔄 READY
# -------------------------------------------------

func _ready():
	light_hits_left = max_light_hits
	heavy_hits_left = max_heavy_hits

# -------------------------------------------------
# 💥 HIT ENTRY POINT
# -------------------------------------------------

func apply_knockback(dmg, kb, attack_data := {}):
	if is_broken:
		return
	
	var attack_type = attack_data.get("type", "light")
	
	match attack_type:
		"light":
			handle_light_hit()
		"heavy":
			handle_heavy_hit()
		_:
			handle_light_hit() # fallback
	
	check_break()

# -------------------------------------------------
# ⚔️ HIT TYPES
# -------------------------------------------------

func handle_light_hit():
	if only_heavy:
		return
	
	light_hits_left -= 1
	feedback_hit()

func handle_heavy_hit():
	if only_light:
		return
	
	heavy_hits_left -= 1
	
	# heavy può anche contribuire ai light (feels better)
	light_hits_left -= 1
	
	feedback_hit(true)

# -------------------------------------------------
# 🔍 BREAK CHECK
# -------------------------------------------------

func check_break():
	if not break_on_zero:
		return
	
	if only_heavy:
		if heavy_hits_left <= 0:
			break_object()
		return
	
	if only_light:
		if light_hits_left <= 0:
			break_object()
		return
	
	# default: uno dei due basta
	if light_hits_left <= 0 or heavy_hits_left <= 0:
		break_object()

# -------------------------------------------------
# 💥 BREAK
# -------------------------------------------------

func break_object():
	if is_broken:
		return
	
	is_broken = true
	
	# disattiva collisione
	collision.disabled = true
	
	# animazione se presente
	if anim and anim.has_animation("break"):
		anim.play("break")
		await anim.animation_finished
	
	spawn_debris()
	queue_free()

# -------------------------------------------------
# ✨ FEEDBACK
# -------------------------------------------------

func feedback_hit(strong := false):
	if flash_on_hit:
		flash()
	
	if shake_on_hit:
		shake(strong)

func flash():
	if sprite == null:
		return
	
	sprite.modulate = Color(2,2,2)
	await get_tree().create_timer(0.05).timeout
	sprite.modulate = Color(1,1,1)

func shake(strong := false):
	if sprite == null:
		return
	
	var intensity = 4 if strong else 2
	
	for i in range(3):
		sprite.position.x += randf_range(-intensity, intensity)
		await get_tree().create_timer(0.01).timeout
	
	sprite.position.x = 0

# -------------------------------------------------
# 🧩 EXTRA
# -------------------------------------------------

func spawn_debris():
	# placeholder: puoi spawnare particelle o pezzi
	print("Spawn debris")
	
	
func on_body_slam(body, force: float):
	if is_broken:
		return
	
	## soglia minima per evitare micro urti
	#if force < 150:
		#return
	
	# ----------------------------------------
	# 💥 TRATTA COME HEAVY HIT
	# ----------------------------------------
	handle_light_hit()
	
	# oppure se vuoi scalare:
	# light_hits_left -= int(force / 100)
	
	check_break()
	
	return is_broken
