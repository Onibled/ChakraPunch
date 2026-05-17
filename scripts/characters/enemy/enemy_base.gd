extends CharacterBody2D
class_name EnemyBase

@export var max_health: int = 100

@onready var health_component: HealthComponent = $HealthComponent
@onready var state_machine: EnemyStateMachine = $StateMachine


@export var gravity: int = 820

# ---------------------------------------------------------
# 🎯 STATI COMBAT
# ---------------------------------------------------------

var is_knockback: bool = false
var is_wall_splat: bool = false
var broke_wall_this_frame: bool = false
var is_airborne: bool = false

var stun_timer: float = 0.0

var stagger_resistance: int = 10

# ---------------------------------------------------------
# 💥 JUGGLE
# ---------------------------------------------------------

var juggle_count: int = 0
var juggle_limit: int = 4
var air_time: float = 0.0


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

# 🧱 Collisions

func try_wall_splat(last_velocity_x):

	if not is_on_wall():
		return
	
	var wall_dir = get_wall_normal().x
	
	if sign(last_velocity_x) == -wall_dir:
		state_machine.change_state("WallSplatState")
	return

func check_breakable_collision(last_velocity_x):

	for i in range(get_slide_collision_count()):

		var collision = get_slide_collision(i)

		var collider = collision.get_collider()

		if collider == null:
			continue

		# deve avere metodo
		if collider.has_method("on_body_slam"):

			# stavi andando verso il muro?
			var wall_normal = collision.get_normal()

			if sign(last_velocity_x) == -sign(wall_normal.x):

				var impact_force = abs(last_velocity_x)

				collider.on_body_slam(self, impact_force)
	return
	
func check_breakable_wall_collision(last_velocity_x: int):
	if state_machine.current_state.name == "WallSplatState":
		return
		
	if not is_knockback:
		return

	for i in range(get_slide_collision_count()):

		var collision = get_slide_collision(i)

		var collider = collision.get_collider()

		if collider == null:
			continue

		# muro rompibile
		if collider.has_method("on_body_slam"):

			var wall_broken = collider.on_body_slam(
				self,
				abs(velocity.x)
			)

			# --------------------------------
			# 💥 MURO ROTTO
			# --------------------------------
			if wall_broken:
				
				broke_wall_this_frame = true

				# mantiene momentum
				velocity.x = sign(last_velocity_x) * max(abs(last_velocity_x), 200)

				# push oltre muro
				global_position.x += sign(velocity.x) * 16

				return

			# --------------------------------
			# 🧱 WALL SPLAT
			# --------------------------------
			else:

				get_node("StateMachine").change_state("WallSplatState")
				return
	return

# ---------------------------------------------------------
# ☠️ DEATH
# ---------------------------------------------------------

func _on_died():
	queue_free()
