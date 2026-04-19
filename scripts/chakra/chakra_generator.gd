extends Activatable
class_name ChakraGenerator

enum AreaType { RECTANGLE, CIRCLE }

@export var area_type: AreaType = AreaType.RECTANGLE

# Dimensioni area
@export var rectangle_size: Vector2 = Vector2(200, 100)
@export var radius: float = 100.0

# Spawn
@export var chakra_scene: PackedScene
@export var max_orbs: int = 10
@export var spawn_interval: float = 1.0

# Stato interno
var active_orbs: Array = []
var timer: float = 0.0


func _process(delta):
	if not is_active:
		return

	timer += delta

	if timer >= spawn_interval:
		timer = 0.0

		if active_orbs.size() < max_orbs:
			spawn_orb()
			
	queue_redraw()
	return
	
func get_spawn_position() -> Vector2:
	if area_type == AreaType.RECTANGLE:
		var x = randf_range(-rectangle_size.x / 2, rectangle_size.x / 2)
		var y = randf_range(-rectangle_size.y / 2, rectangle_size.y / 2)
		return global_position + Vector2(x, y)
	else:
		# distribuzione uniforme nel cerchio
		var angle = randf() * TAU
		var dist = sqrt(randf()) * radius
		var offset = Vector2.from_angle(angle) * dist
		return global_position + offset
	
	return Vector2.ZERO
		
func spawn_orb():
	if chakra_scene == null:
		push_warning("ChakraGenerator: chakra_scene non assegnata!")
		return

	var orb = chakra_scene.instantiate()
	orb.global_position = get_spawn_position()

	get_tree().current_scene.add_child(orb)

	active_orbs.append(orb)

	if orb.has_signal("orb_destroyed"):
		orb.orb_destroyed.connect(_on_orb_destroyed)
	return

func _on_orb_destroyed(orb):
	active_orbs.erase(orb)
	return

func _on_activated():
	timer = 0.0
	# opzionale: print("Generator attivato")
	return

func _on_deactivated():
	timer = 0.0
	# opzionale: print("Generator disattivato")
	return

func _draw():
	if area_type == AreaType.RECTANGLE:
		draw_rect(Rect2(-rectangle_size / 2, rectangle_size), Color.CYAN, false)
	else:
		draw_circle(Vector2.ZERO, radius, Color.CYAN)
	return
	
