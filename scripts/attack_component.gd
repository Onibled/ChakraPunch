extends Node

@export var hitbox: Area2D

var body: CharacterBody2D
var movement
var cooldown := 0.0

func _ready():
	body = get_parent()
	movement = body.get_node("MovementComponent")

# ---------------------------------------------------------

func update(delta):
	cooldown = max(cooldown - delta, 0)

# ---------------------------------------------------------

func try_attack(target: Node2D):
	if cooldown > 0:
		return
	
	var dist = body.global_position.distance_to(target.global_position)
	
	if dist < 40:
		await scratch()
	else:
		await leap(target)

# ---------------------------------------------------------

func scratch():
	cooldown = 0.8
	
	movement.stop()
	
	await body.get_tree().create_timer(0.2).timeout
	
	hitbox.start_hit()
	
	await body.get_tree().create_timer(0.2).timeout
	
	hitbox.stop_hit()

# ---------------------------------------------------------

func leap(target):
	cooldown = 1.2
	
	movement.leap(target)
	
	hitbox.start_hit()
	
	await body.get_tree().create_timer(0.4).timeout
	
	hitbox.stop_hit()
