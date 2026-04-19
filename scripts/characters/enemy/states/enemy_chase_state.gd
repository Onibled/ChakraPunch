extends StateEnemy

func update(delta):

	if enemy.target == null:
		state_machine.change_state("PatrolState")
		return

	enemy.movement.move_chase(enemy.target)
