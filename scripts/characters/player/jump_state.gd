extends StatePlayer

func enter():
	player.anim.play("jump")
	player.velocity.y = player.jump_force
	return

func update(delta):
	player.handle_movement(delta)
	player.handle_jump()
	
	if player.velocity.y > 0:
		state_machine.change_state("FallState")
		return
		
	player.check_ledge()
	if player.is_on_ledge:
		state_machine.change_state("LedgeState")
		return

	return
