extends StateEnemy

func enter():
	return

func update(delta):
	# torna subito neutro
	
	# gravità (se serve)
	state_machine.change_state("PatrolState")
	
	enemy.move_and_slide()
	return
