extends StateEnemy

func enter():
	await enemy.attack.try_attack(enemy.target)
	
	if enemy.target:
		state_machine.change_state("ChaseState")
	else:
		state_machine.change_state("PatrolState")
