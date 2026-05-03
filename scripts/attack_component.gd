extends Node

@export var hitbox: Area2D

var body: CharacterBody2D
var movement

var cooldown := 0.0
var is_attacking := false

# ---------------------------------------------------------

func _ready():
	body = get_parent()
	movement = body.get_node("MovementComponent")

# ---------------------------------------------------------

func update(delta):
	# cooldown countdown
	if cooldown > 0:
		cooldown -= delta

# ---------------------------------------------------------

func try_attack(target: Node2D):
	# blocchi fondamentali
	if cooldown > 0 or is_attacking:
		return
	
	if target == null:
		return
	
	var dist = body.global_position.distance_to(target.global_position)
	
	if dist < 40:
		scratch()
	else:
		leap(target)

# ---------------------------------------------------------

func scratch():
	is_attacking = true
	cooldown = 0.8
	
	movement.stop()
	
	_do_scratch()

# ---------------------------------------------------------

func _do_scratch() -> void:
	await body.get_tree().create_timer(0.2).timeout
	
	hitbox.start_hit()
	
	await body.get_tree().create_timer(0.2).timeout
	
	hitbox.stop_hit()
	
	is_attacking = false

# ---------------------------------------------------------

func leap(target):
	is_attacking = true
	cooldown = 1.2
	
	movement.leap(target)
	
	_do_leap()

# ---------------------------------------------------------

func _do_leap() -> void:
	hitbox.start_hit()
	
	await body.get_tree().create_timer(0.4).timeout
	
	hitbox.stop_hit()
	
	is_attacking = false
