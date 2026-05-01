extends EnemyBase

# ---------------------------------------------------------
# 🌍 PHYSICS
# ---------------------------------------------------------

@export var max_fall_speed := 500

@export var friction := 800


# ---------------------------------------------------------
# 🔄 MAIN LOOP
# ---------------------------------------------------------

func _physics_process(delta):
	handle_gravity(delta)
	
	# Reset quando tocca terra
	if is_on_floor():
		is_airborne = false
		juggle_count = 0
	
	# Gestione stati
	if is_wall_splat:
		handle_wall_splat(delta)
	elif is_knockback:
		handle_knockback(delta)
	
	# Collisioni avanzate
	handle_wall_collision()
	handle_ground_collision()
	
	apply_friction(delta)
	
	if abs(velocity.x) < 5:
		velocity.x = 0
		
	stabilize_in_air()
	
	var last_velocity_x = velocity.x
	
	move_and_slide()

	# -------------------------
	# WALL SPLAT CHECK
	# -------------------------
	if is_on_wall():
		var wall_dir = get_wall_normal().x
		
		# stai andando verso il muro?
		if sign(last_velocity_x) == -wall_dir:
			get_node("StateMachine").change_state("WallSplatState")
			return
			
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			
			if collider and collider.has_method("on_body_slam"):
				var impact_force = abs(velocity.x)
				collider.on_body_slam(self, impact_force)
		

func spawn_chakra(dmg, kb: Vector2):
	var dir = sign(kb.x)
	if dir == 0:
		dir = 1
	
	#var orb_count = clamp(dmg / 5, 1, 5)
	var orb_count = 1

	for i in range(orb_count):
		var orb = preload("res://scenes/chakra_orb.tscn").instantiate()
		orb.global_position = global_position
		
		get_parent().add_child(orb)
		
		orb.launch(dir)

# ---------------------------------------------------------
# 💫 KNOCKBACK
# ---------------------------------------------------------

func handle_knockback(delta):
	stun_timer -= delta
	
	# Wall splat check
	if is_on_wall() and abs(velocity.x) > 200:
		get_node("StateMachine").change_state("WallSplatState")
		return
	
	# Fine knockback
	if stun_timer <= 0:
		is_knockback = false
		
	# Anti infinite combo
	if juggle_count > juggle_limit:
		velocity.y = max(velocity.y, 200)
		
	

# ---------------------------------------------------------
# 🧱 WALL SPLAT
# ---------------------------------------------------------

## Attivato quando sbatte contro muro
func start_wall_splat():
	is_wall_splat = true
	is_knockback = false
	stun_timer = 0.4
	velocity = Vector2.ZERO

## Nemico bloccato al muro
func handle_wall_splat(delta):
	stun_timer -= delta
	
	velocity = Vector2.ZERO
	
	if stun_timer <= 0:
		is_wall_splat = false
		
# ---------------------------------------------------------
# 🧱 COLLISIONI AVANZATE
# ---------------------------------------------------------

## Rimbalzo su muro (air combo)
func handle_wall_collision():
	if is_on_wall() and is_airborne:
		velocity.x *= -0.6
		velocity.y *= 0.8
		
		juggle_count += 1

## Rimbalzo a terra
func handle_ground_collision():
	if is_on_floor() and is_airborne:
		
		if velocity.y > 300:
			velocity.y = -200  # rimbalzo
		else:
			is_airborne = false
			
# ---------------------------------------------------------
# 🌍 GRAVITY + FLOAT SYSTEM
# ---------------------------------------------------------

func handle_gravity(delta):
	if not is_on_floor():
		air_time += delta
		
		# -------------------------------------------------
		# 🎈 FLOAT TIME
		# rallenta caduta all'inizio del juggling
		# -------------------------------------------------
		var float_factor := 1.0
		
		if air_time < 0.3:
			float_factor = 0.6  # più float all'inizio
		
		# -------------------------------------------------
		# 📉 GRAVITY SCALING
		# più colpi → cade più veloce
		# -------------------------------------------------
		var gravity_multiplier = 1.0 + (juggle_count * 0.3)
		
		velocity.y += gravity * gravity_multiplier * float_factor * delta
		velocity.y = min(velocity.y, max_fall_speed)

#################
## Movement
#################

func apply_friction(delta):
	if is_knockback:
		return
		
	var current_friction = friction
	
	## meno attrito durante knockback
	if is_knockback:
		current_friction *= 0.3
	
	# ancora meno in aria
	if is_airborne:
		current_friction *= 0.2
	
	velocity.x = move_toward(velocity.x, 0, current_friction * delta)



func stabilize_in_air():
	if not is_airborne:
		return
	
	# rallenta caduta durante combo
	if juggle_count > 0:
		velocity.y *= 0.9


func limit_fall_during_combo():
	if juggle_count > 1:
		velocity.y = min(velocity.y, 150)
		
		
func _on_died():
	queue_free()
