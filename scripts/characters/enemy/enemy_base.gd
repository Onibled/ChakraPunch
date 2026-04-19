extends CharacterBody2D
class_name EnemyBase

@export var max_health := 100

@onready var health_component: HealthComponent = $HealthComponent
@onready var state_machine = $StateMachine


@export var gravity := 820

# ---------------------------------------------------------
# 🎯 STATI COMBAT
# ---------------------------------------------------------

var is_knockback := false
var is_wall_splat := false
var is_airborne := false

var stun_timer := 0.0

var stagger_resistance := 10

# ---------------------------------------------------------
# 💥 JUGGLE
# ---------------------------------------------------------

var juggle_count := 0
var juggle_limit := 4
var air_time := 0.0


# ---------------------------------------------------------
# 🔄 READY
# ---------------------------------------------------------

func _ready():
	health_component.set_max_health(max_health)
	health_component.died.connect(_on_died)

# ---------------------------------------------------------
# 💥 APPLY HIT (CORE)
# ---------------------------------------------------------

func apply_knockback(dmg, kb: Vector2, attack_data := {}):

	if health_component.health <= 0:
		return

	health_component.damage(dmg)

	velocity = kb
	
	is_knockback = true
	is_airborne = kb.y < 0
	stun_timer = attack_data.get("stun", 0.2)

	var reaction = attack_data.get("reaction", "knockback")

	match reaction:
		"stagger":
			state_machine.change_state("HitState")
		
		"knockback":
			state_machine.change_state("HitState")
		
		"launch":
			is_airborne = true
			state_machine.change_state("AirState")
		
		_:
			state_machine.change_state("HitState")

	spawn_chakra(dmg, kb)

# ---------------------------------------------------------
# 💫 CHAKRA DROP
# ---------------------------------------------------------

func spawn_chakra(dmg, kb: Vector2):
	var dir = sign(kb.x)
	if dir == 0:
		dir = 1
	
	var orb = preload("res://scenes/chakra_orb.tscn").instantiate()
	orb.global_position = global_position
	
	get_parent().add_child(orb)
	orb.launch(dir)

# ---------------------------------------------------------
# 💥 KNOCKBACK UPDATE
# ---------------------------------------------------------

func update_knockback(delta):
	stun_timer -= delta

	if stun_timer <= 0:
		is_knockback = false

# ---------------------------------------------------------
# 🧱 WALL SPLAT
# ---------------------------------------------------------

func try_wall_splat(last_velocity_x):

	if not is_on_wall():
		return
	
	var wall_dir = get_wall_normal().x
	
	if sign(last_velocity_x) == -wall_dir:
		state_machine.change_state("WallSplatState")

# ---------------------------------------------------------
# ☠️ DEATH
# ---------------------------------------------------------

func _on_died():
	queue_free()
