extends Area2D

# -------------------------------------------------
# ⚙️ SETTINGS
# -------------------------------------------------

@export var base_speed := 120.0
@export var max_speed := 500.0
@export var acceleration := 800.0

@export var magnet_radius := 180.0

@export var lifetime := 6.0
@export var blink_start := 4.0

@export var snap_distance := 10.0

var target = null
var velocity := Vector2.ZERO

var current_speed := 0.0

var launch_phase := true
var can_be_absorbed := false

var life_timer := 0.0
var blink_timer := 0.0

var magnet_sound_played := false

signal orb_destroyed(orb)

# -------------------------------------------------
# 🔗 REFERENCES
# -------------------------------------------------

@onready var magnet_sound: AudioStreamPlayer2D = $MagnetSound
@onready var pickup_sound: AudioStreamPlayer2D = $PickupSound

# -------------------------------------------------
# 🔄 READY
# -------------------------------------------------

func _ready():
	add_to_group("chakra")
	
	modulate.a = 0.3
	scale = Vector2(0.6, 0.6)
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1,1), 0.2)
	
	await get_tree().create_timer(0.5).timeout
	
	can_be_absorbed = true
	current_speed = base_speed
	
	var fade = create_tween()
	fade.tween_property(self, "modulate:a", 1.0, 0.2)

# -------------------------------------------------
# 🚀 LAUNCH
# -------------------------------------------------

func launch(dir: int):
	if dir == 0:
		dir = 1
	
	var vx = randf_range(100, 150) * dir
	var vy = randf_range(-120, -40)
	
	velocity = Vector2(vx, vy)
	velocity = velocity.rotated(randf_range(-0.3, 0.3))

# -------------------------------------------------
# 🔄 PROCESS
# -------------------------------------------------

func _process(delta):
	
	handle_lifetime(delta)
	
	# ----------------------------------------
	# 🚀 FASE DI LANCIO
	# ----------------------------------------
	
	if launch_phase:
		global_position += velocity * delta
		velocity = velocity.move_toward(Vector2.ZERO, 200 * delta)
		
		if velocity.length() < 20:
			launch_phase = false
		return
	
	# ----------------------------------------
	# 🧍 TROVA PLAYER
	# ----------------------------------------
	
	if target == null:
		find_player()
	
	if target == null:
		float_idle()
		return
	
	# ----------------------------------------
	# 🧘 CONTROLLO MEDITAZIONE
	# ----------------------------------------
	
	if not can_be_absorbed or not target.meditating:
		float_idle()
		return
	
	# ----------------------------------------
	# 🧲 MAGNET SYSTEM
	# ----------------------------------------
	
	var dist = global_position.distance_to(target.global_position)
	
	if dist < magnet_radius:
		
		# 🎧 suono attrazione (solo una volta)
		if not magnet_sound_played:
			magnet_sound.play()
			magnet_sound_played = true
		
		# 🎯 SNAP FINALE
		if dist < snap_distance:
			collect(target)
			return
		
		# 🎯 curva non lineare
		var t = clamp(dist / magnet_radius, 0.0, 1.0)
		var speed_factor = 1.0 - (t * t)
		
		var target_speed = lerp(base_speed, max_speed, speed_factor)
		current_speed = move_toward(current_speed, target_speed, acceleration * delta)
		
		var dir = (target.global_position - global_position).normalized()
		global_position += dir * current_speed * delta
		
	else:
		float_idle()

# -------------------------------------------------
# 💥 RACCOLTA
# -------------------------------------------------

func collect(body):
	if not can_be_absorbed || (target != null && not target.meditating):
		return
	
	if body.has_method("add_chakra"):
		body.add_chakra(10)
		
		if pickup_sound.stream:
			var snd = pickup_sound.duplicate()
			get_tree().current_scene.add_child(snd)
			snd.global_position = global_position
			snd.play()
		
		queue_free()

func _on_body_entered(body):
	if not can_be_absorbed:
		return
	
	if body.has_method("add_chakra"):
		collect(body)

# -------------------------------------------------
# ⏳ LIFETIME + BLINK
# -------------------------------------------------

func handle_lifetime(delta):
	life_timer += delta
	
	if life_timer >= blink_start:
		blink_timer += delta
		
		var blink_speed = lerp(2.0, 10.0, (life_timer - blink_start) / (lifetime - blink_start))
		modulate.a = 0.5 + sin(blink_timer * blink_speed) * 0.5
	
	if life_timer >= lifetime:
		queue_free()

# -------------------------------------------------
# 🧍 CERCA PLAYER
# -------------------------------------------------

func find_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]

# -------------------------------------------------
# 🌊 FLOAT IDLE
# -------------------------------------------------

func float_idle():
	global_position.y += sin(Time.get_ticks_msec() * 0.005) * 0.3

# -------------------------------------------------
# 🧹 CLEANUP
# -------------------------------------------------

func _exit_tree():
	orb_destroyed.emit(self)

# -------------------------------------------------
# 🎨 DEBUG
# -------------------------------------------------

func _draw():
	draw_circle(Vector2.ZERO, magnet_radius, Color.CYAN, false)
