extends CharacterBody2D
class_name Player

# =========================================================
# 🧍 PLAYER CONTROLLER
# Gestisce:
# - movimento
# - combattimento
# - interazioni (ledge, chakra)
# - integrazione con StateMachine
# =========================================================

#region HEALTH

signal health_changed(value)
signal died
@onready var health_component: HealthComponent = $HealthComponent

#endregion

#region MOVEMENT SETTINGS

## Direzione attuale del player (1 = destra, -1 = sinistra)
var facing_direction := 1

@export var max_speed := 220
@export var acceleration := 1200
@export var friction := 1000

@export var jump_force := -200
@export var gravity := 820
@export var gravity_fall := 1220

## Miglioramenti qualità salto
@export var coyote_time := 0.1
@export var jump_buffer_time := 0.1

var coyote_timer := 0.0
var jump_buffer_timer := 0.0

@export var turn_speed := 1500

# FALL
@export var max_fall_speed := 500

# CONTROLLO ARIA
@export var air_acceleration := 800

#endregion

#region COLLISIONS
var saved_collision_position
var saved_collision_scale

var saved_hurtbox_position
var saved_hurtbox_scale
#endregion

#region DASH

@export var dash_speed := 300
@export var dash_cooldown := 0.2

var is_dashing := false
var dash_cooldown_timer := 0.0
var dash_direction := 0

@export var dash_cancel_enabled := true
@export var dash_cancel_requires_hit := false

#endregion

#region I-FRAMES

@export var dash_invincible := true
@export var dash_iframe_time := 0.15

var is_invincible := false
var iframe_timer := 0.0

#endregion

#region WALL

## Parametri wall interaction
@export var wall_slide_speed := 60.0
@export var wall_jump_x := 300
@export var wall_jump_y := -420

var is_wall_sliding := false

#endregion

#region LEDGE

## Stato aggrappamento bordo
var is_on_ledge := false
var ledge_position := Vector2.ZERO

## Cooldown per evitare riaggancio immediato
var ledge_cooldown := 0.2
var ledge_timer := 0.0

#endregion

#region COMBAT

@export var light_damage := 10
@export var heavy_force := 600

## Tipo attacco corrente (light/heavy)
var attack_type := ""

var combo_step := 0
var combo_timer := 0.0
var combo_window := 0.4

@export var launcher_force := -500

var current_attack := "light_1"

var combo_data = {
	"light_1": {
		"anim": "attack_light",
		"damage": 10,
		"kb": Vector2(5, -100),
		"next": ["light_2", "heavy"],
		"dash_cancel": true,
		"confirm_start": 0.08,
		"confirm_end": 0.22
	},
	
	"light_2": {
		"anim": "attack_light_2",
		"damage": 12,
		"kb": Vector2(5, -120),
		"next": ["heavy"],
		"dash_cancel": true,
		"confirm_start": 0.08,
		"confirm_end": 0.22,
		"reaction": "stagger"
	},
	
	"heavy": {
		"anim": "attack_heavy",
		"damage": 20,
		"kb": Vector2(200, -300),
		"next": [],
		"dash_cancel": false,
		"confirm_start": 0.00,
		"confirm_end": 0.35,
		"reaction": "knockback"
	},
	
	"launcher": {
		"anim": "launcher",
		"damage": 15,
		"kb": Vector2(0, -500),
		"next": ["light_1"],  # air follow
		"dash_cancel": true,
		"confirm_start": 0.08,
		"confirm_end": 0.22,
		"reaction": "launch"
	}
}

var combo_target: CharacterBody2D = null

var has_hit := false

#endregion

#region CHAKRA

var chakra: float = 0.0
var max_chakra: float = 300
var meditating: bool = false
signal chakra_changed(value)

#endregion

#region STATI

var can_move := true
@export var meditate_speed_multiplier := 0.25
@onready var state_machine: PlayerStateMachine = $StateMachine

#endregion

#region CAST DATA

var cast_data := {}

#endregion

# ---------------------------------------------------------
# 🔗 NODE REFERENCES
# ---------------------------------------------------------

@onready var visuals: Node2D = $Visuals

## Sprite e animazioni
@onready var anim = $Visuals/AnimationPlayer
@onready var sprite = $Visuals/Sprite2D

## Boxes
@onready var collision_box: CollisionShape2D = $CollisionBox
@onready var hurtbox: Area2D = $Visuals/Hurtbox
@onready var hitbox: Area2D = $Visuals/Hitbox

## Ledge detection
@onready var ledge_check_top: RayCast2D = $Visuals/LedgeCheckTop
@onready var ledge_check_bottom: RayCast2D = $Visuals/LedgeCheckBottom

## Input buffer (sistema esterno)
@onready var input_buffer = InputBuffer.new()

# ---------------------------------------------------------
# 🔄 LIFECYCLE
# ---------------------------------------------------------

func _ready():
	add_child(input_buffer)
	load_state()
	add_to_group("player")
	
	save_collision_state()
	
	health_component.died.connect(_on_died)
	emit_signal("health_changed", health_component.health)
	return

func _physics_process(delta):
	handle_timers(delta)
	handle_input_buffer()
	input_buffer.update(delta)
	
	handle_gravity(delta)
	handle_iframes(delta)
	handle_attacks()
	
	move_and_slide()
	
	return

# ---------------------------------------------------------
# 🏃 MOVEMENT
# ---------------------------------------------------------

func handle_movement(delta):
	if is_on_ledge || is_dashing:
		return
		
	var dir = Input.get_axis("ui_left", "ui_right")
	
	# Aggiorna direzione e flip visuals
	if dir != 0:
		facing_direction = dir
		visuals.scale.x = facing_direction
	
	var accel = acceleration if is_on_floor() else air_acceleration
	
	var speed_mult = meditate_speed_multiplier if meditating else 1.0
	
	# Cambio direzione più rapido
	if dir != 0 and sign(velocity.x) != sign(dir):
		velocity.x = move_toward(velocity.x, dir * max_speed * speed_mult, turn_speed * delta)
	else:
		velocity.x = move_toward(velocity.x, dir * max_speed * speed_mult, accel * delta)
	return

func force_reset_movement_state():
	if is_dashing:
		end_dash()

## Esegue il Dash

func start_dash():
	is_dashing = true
	
	var dir = Input.get_axis("ui_left", "ui_right")
	if dir == 0:
		dir = facing_direction
	
	dash_direction = dir
	
	velocity = Vector2.ZERO
	velocity.x = dash_direction * dash_speed
	
	dash_cooldown_timer = dash_cooldown
	
	if dash_invincible:
		start_iframes(dash_iframe_time)
	
	apply_dash_collision()
	
	anim.play("slide")
	return
	
func update_dash(delta):
	velocity.x = dash_direction * dash_speed
	return
	
func on_dash_finished():
	end_dash()
	return
	
func end_dash():
	if not is_dashing:
		return
		
	is_dashing = false
	restore_collision_state()
	return
	
func can_dash() -> bool:
	return dash_cooldown_timer <= 0 and not is_dashing

func handle_air_control(delta):
	if is_on_floor():
		return
	
	var dir = Input.get_axis("ui_left", "ui_right")
	
	# controllo più preciso in aria
	velocity.x = move_toward(velocity.x, dir * max_speed, air_acceleration * delta)
	return
	
func try_dash_cancel() -> bool:
	if not dash_cancel_enabled:
		return false
	
	if not can_dash():
		return false
	
	if dash_cancel_requires_hit and not has_hit:
		return false

	
	if input_buffer.consume("dash"):
		state_machine.change_state("DashState")
		return true
	
	return false
	
	
# COLLISIONS

func save_collision_state():
	saved_collision_position = collision_box.position
	saved_collision_scale = collision_box.scale
	
	saved_hurtbox_position = hurtbox.position
	saved_hurtbox_scale = hurtbox.scale
	return
	
func apply_dash_collision():
	collision_box.scale = Vector2(0.52, 0.2)  # esempio più basso
	collision_box.position = Vector2(-2.5, 24.5)
	
	hurtbox.scale = Vector2(0.8, 0.5)
	return
	
func restore_collision_state():
	collision_box.position = saved_collision_position
	collision_box.scale = saved_collision_scale
	
	hurtbox.position = saved_hurtbox_position
	hurtbox.scale = saved_hurtbox_scale
	return
	
# ---------------------------------------------------------
# I-FRAMES
# ---------------------------------------------------------

func start_iframes(duration):
	is_invincible = true
	iframe_timer = duration
	hurtbox.monitoring = false

func handle_iframes(delta):
	if not is_invincible:
		return
	
	iframe_timer -= delta
	
	if iframe_timer <= 0:
		is_invincible = false
		hurtbox.monitoring = true
	return

# ---------------------------------------------------------
# 🌍 GRAVITY
# ---------------------------------------------------------

func handle_gravity(delta):
	if not is_on_floor() && !state_machine.current_state.name == "LedgeState":
		if velocity.y <= 0:
			velocity.y += gravity * delta
		else:
			velocity.y += gravity_fall * delta
		velocity.y = min(velocity.y, max_fall_speed)
	return

# ---------------------------------------------------------
# 🪂 JUMP SYSTEM
# ---------------------------------------------------------

## Gestione timers + buffer input + coyote time
func handle_timers(delta):
	dash_cooldown_timer = max(dash_cooldown_timer - delta, 0)
	
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer = max(coyote_timer - delta, 0)

	if input_buffer.consume("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer = max(jump_buffer_timer - delta, 0)
		
	ledge_timer = max(ledge_timer - delta, 0)
	
	return
	
func handle_input_buffer():
	if Input.is_action_just_pressed("light_attack"):
		input_buffer.add_input("light_attack")

	if Input.is_action_just_pressed("heavy_attack"):
		input_buffer.add_input("heavy_attack")
		
	if Input.is_action_just_pressed("dash"):
		input_buffer.add_input("dash")

	if Input.is_action_just_pressed("jump"):
		input_buffer.add_input("jump")
		
	if Input.is_action_just_pressed("interact"):
		input_buffer.add_input("interact")
		
	return


## Logica salto (terra + muro)
func handle_jump():
	if is_on_ledge || meditating:
		return
		
	if jump_buffer_timer > 0:
		# Salto normale
		if coyote_timer > 0:
			velocity.y = jump_force
			reset_jump()
			return
		
		# Wall jump
		if is_on_wall():
			var wall_dir = get_wall_normal().x
			velocity.x = wall_dir * wall_jump_x
			velocity.y = wall_jump_y
			reset_jump()
			return

	# Salto variabile (taglio altezza)
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5
	return

func reset_jump():
	jump_buffer_timer = 0
	coyote_timer = 0
	return

# ---------------------------------------------------------
# 🧗 WALL
# ---------------------------------------------------------

func handle_wall_slide():
	is_wall_sliding = false
	
	if is_on_wall() and not is_on_floor() and velocity.y > 0:
		is_wall_sliding = true
		velocity.y = min(velocity.y, wall_slide_speed)
	return

# ---------------------------------------------------------
# ⚔️ COMBAT INPUT
# ---------------------------------------------------------

func handle_attacks() -> void:
	if is_on_ledge || is_dashing || meditating:
		return
		
	var up_pressed = Input.is_action_pressed("ui_up")
	
	if input_buffer.consume("light_attack"):
		attack_type = "launcher" if up_pressed else "light"
		state_machine.change_state("AttackState")
		
	if input_buffer.consume("heavy_attack"):
		attack_type = "heavy"
		state_machine.change_state("AttackState")
	return
# ---------------------------------------------------------
# 🧗 LEDGE SYSTEM
# ---------------------------------------------------------

## Controllo se il player può agganciarsi
func check_ledge():
	if is_on_ledge || is_on_floor() || ledge_timer > 0:
		return
	
	var top = ledge_check_top.is_colliding()
	var bottom = ledge_check_bottom.is_colliding()
	
	if not top and bottom and velocity.y > 50:
		grab_ledge()
	return

func grab_ledge():
	is_on_ledge = true
	velocity = Vector2.ZERO
	return
	
func handle_ledge():
	velocity = Vector2.ZERO
	
	# SALI
	if input_buffer.consume("jump"):
		climb_ledge()
	
	# LASCIA
	if Input.is_action_pressed("ui_down"):
		drop_ledge()
	
	# SALTO DA LEDGE
	if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
		jump_from_ledge()
	return

func climb_ledge():
	is_on_ledge = false
	
	# teletrasporto sopra il bordo
	global_position.y -= 30
	global_position.x += 10 * facing_direction
	return

func drop_ledge():
	is_on_ledge = false
	velocity.y = 50
	ledge_timer = ledge_cooldown
	return
	
func jump_from_ledge():
	is_on_ledge = false
	velocity.y = jump_force
	velocity.x = -sign(ledge_check_bottom.get_collision_normal().x) * wall_jump_x
	ledge_timer = ledge_cooldown
	return
	
# -------------------
# COMBAT
# -------------------

func apply_knockback(dmg, kb, attack_data := {}):
	if is_invincible:
		return
		
	force_reset_movement_state()
		
	health_component.damage(dmg)
	emit_signal("health_changed", health_component.health)
	
	var reaction = attack_data.get("reaction", "stagger")
	
	match reaction:
		"stagger":
			start_stagger(kb)
		
		"knockback":
			start_knockback(kb)
		
		"launch":
			start_launch(kb)
		
		_:
			start_stagger(kb)
	return
	
func start_stagger(kb: Vector2):
	velocity = kb * 0.3  # pochissimo movimento
	
	state_machine.change_state("StaggerState")
	return

func start_knockback(kb: Vector2):
	velocity = kb
	state_machine.change_state("KnockbackState")
	return

func start_launch(kb: Vector2):
	velocity = kb
	state_machine.change_state("AirHitState")
	return

# -------------------
# CHAKRA SYSTEM
# -------------------

func add_chakra(value: int):
	chakra = clamp(chakra + value, 0, max_chakra)
	emit_signal("chakra_changed", chakra)
	return

# -------------------
# SPECIAL ATTACKS
# -------------------

func attack_speed_buff():
	print("Buff velocità attacco attivo!")
	return
	
func _on_damaged(dmg, kb):
	print("Preso danno:", dmg)
	velocity += kb
	return
	
func set_combo_target(target):
	if target is CharacterBody2D:
		combo_target = target
	return
	
func clear_combo_target():
	set_combo_target(null)
	return
	
func handle_combo_follow(delta):
	if combo_target == null:
		return
		
	# distanza dal target
	var dist = global_position.distance_to(combo_target.global_position)
	
	# troppo lontano → perdi target
	if dist > 200:
		combo_target = null
		return
	
	# -------------------------------------------------
	# 🎯 FOLLOW ORIZZONTALE
	# -------------------------------------------------
	
	var dir = sign(combo_target.global_position.x - global_position.x)
	velocity.x = move_toward(velocity.x, dir * max_speed, 1200 * delta)
	
	# -------------------------------------------------
	# 🎯 FOLLOW VERTICALE (leggero)
	# -------------------------------------------------
	
	if combo_target.global_position.y < global_position.y:
		velocity.y -= 600 * delta


func handle_air_combo_control(delta):
	if combo_target == null:
		return
		
	var dir = Input.get_axis("ui_left", "ui_right")
	
	# controlli la direzione della combo
	if dir != 0:
		velocity.x += dir * 600 * delta
	
	# leggero controllo verticale
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 500 * delta
		
	if Input.is_action_pressed("ui_down"):
		velocity.y += 500 * delta
		
		
func register_hit():
	has_hit = true
	return
	
# ---------------------------------------------------------
# 🎬 ANIMATION CALLBACKS
# ---------------------------------------------------------

func _on_animation_player_animation_finished(anim_name):
	if anim_name == null:
		state_machine.change_state("MoveState")
		return
		
	if anim_name.begins_with("attack"):
		combo_timer = combo_window
		if is_on_floor():
			state_machine.change_state("MoveState")
		else:
			state_machine.change_state("FallState")
	return
	
## Abilita cancel window (chiamato da AnimationPlayer)
func enable_cancel():
	state_machine.current_state.can_cancel = true
	return

## Disabilita cancel window
func disable_cancel():
	state_machine.current_state.can_cancel = false
	return
	
func save_state():
	GameState.player_health = health_component.health
	GameState.player_chakra = chakra
	return

func load_state():
	health_component.set_health(GameState.player_health)
	chakra = GameState.player_chakra
	return

func _on_died():
	print("Player morto")
	
	# esempio con checkpoint
	#Utility.change_scene(load(GameState.last_scene))
