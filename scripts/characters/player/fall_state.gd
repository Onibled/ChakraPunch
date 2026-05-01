extends StatePlayer

func enter():
	player.anim.play("fall")
	return
	
func update(delta):
	player.handle_movement(delta)
	
	if player.is_on_floor():
		state_machine.change_state("MoveState")
		return
	
	player.check_ledge()
	if player.is_on_ledge:
		state_machine.change_state("LedgeState")
		return
	
	if player.is_on_wall():
		state_machine.change_state("WallState")
		return
	return
