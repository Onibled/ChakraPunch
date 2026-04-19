extends EnemyBase

@onready var movement = $MovementComponent
@onready var detection = $DetectionComponent
@onready var attack = $AttackComponent
@onready var ground_ray = $GroundRay

var target: Node2D = null

# ---------------------------------------------------------

func _ready():
	detection.player_detected.connect(_on_detected)
	detection.player_lost.connect(_on_lost)
	detection.player_in_range.connect(_on_attack)
	detection.player_out_range.connect(_on_attack_lost)

# ---------------------------------------------------------

func _physics_process(delta):

	movement.apply_gravity(delta)
	attack.update(delta)

	var last_velocity_x = velocity.x

	move_and_slide()

	# wall splat centralizzato
	try_wall_splat(last_velocity_x)

# ---------------------------------------------------------

func _on_detected(player):
	target = player
	state_machine.change_state("ChaseState")

func _on_lost():
	target = null
	state_machine.change_state("PatrolState")

func _on_attack(player):
	state_machine.change_state("AttackState")

func _on_attack_lost():
	if target:
		state_machine.change_state("ChaseState")

# ---------------------------------------------------------

func flip():
	movement.direction *= -1
	update_ground_ray()

func update_ground_ray():
	ground_ray.position.x = 26 * movement.direction
