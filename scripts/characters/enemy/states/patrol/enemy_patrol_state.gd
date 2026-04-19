extends StateEnemy

@onready var ground_ray = $"../../GroundRay"

func update(delta):

	enemy.movement.move_patrol()

	if enemy.is_on_wall():
		enemy.flip()

	if not ground_ray.is_colliding():
		enemy.flip()
