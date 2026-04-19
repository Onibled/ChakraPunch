extends StateEnemy

func enter():
	return

func update(delta):
	# torna subito neutro
	
	# gravità (se serve)
	if not enemy.is_on_floor():
		state_machine.change_state("AirState")
		return
	
	enemy.move_and_slide()
	return
