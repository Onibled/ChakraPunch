extends Activatable

@onready var moving_platform: CharacterBody2D = $MovingPlatform


@export var speed: float = 120.0
@export var active: bool = true

enum LoopMode { STOP, LOOP, PINGPONG }
@export var loop_mode: LoopMode = LoopMode.PINGPONG

@export var reach_threshold: float = 5.0

# 👉 PUNTI GLOBALI
@export var points: Array[Vector2] = []

func _ready():
	moving_platform.speed = speed
	moving_platform.active = active
	moving_platform.loop_mode = loop_mode
	moving_platform.reach_threshold = reach_threshold
	moving_platform.points = points
	if points.is_empty():
		push_error("MovingPlatform: nessun punto impostato")
		moving_platform.set_physics_process(false)
	else:
		moving_platform.set_physics_process(true)
	return

func activate():
	moving_platform.activate()
	return
	
func is_actived_now() -> bool: 
	return moving_platform.active
