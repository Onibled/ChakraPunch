extends Node

@export var speed := 100
@export var gravity := 900
@export var max_fall_speed := 500

var body: CharacterBody2D
var direction := 1

func _ready():
	body = get_parent()

# ---------------------------------------------------------

func apply_gravity(delta):
	if not body.is_on_floor():
		body.velocity.y += gravity * delta
		body.velocity.y = min(body.velocity.y, max_fall_speed)

# ---------------------------------------------------------

func move_patrol():
	body.velocity.x = direction * speed

func move_chase(target: Node2D):
	var dir = sign(target.global_position.x - body.global_position.x)
	direction = dir
	body.velocity.x = dir * speed * 1.3

# ---------------------------------------------------------

func stop():
	body.velocity.x = move_toward(body.velocity.x, 0, 1000)

# ---------------------------------------------------------

func leap(target: Node2D, force_x := 250, force_y := -250):
	var dir = sign(target.global_position.x - body.global_position.x)
	direction = dir
	
	body.velocity.x = dir * force_x
	body.velocity.y = force_y
