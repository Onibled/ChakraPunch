extends StatePlayer

func enter():
	pass

func update(delta):
	player.handle_movement(delta)
	
	if abs(player.velocity.x) > 40:
		player.anim.play("run")
	else:
		player.anim.play("idle")
	
	if player.input_buffer.consume("jump"):
		if player.is_on_floor():
			state_machine.change_state("JumpState")
		else:
			player.handle_jump()
		return
			
	if Input.is_action_pressed("meditate") and player.is_on_floor():
		state_machine.change_state("MeditateState")
		return
		
	if player.input_buffer.consume("dash") and player.is_on_floor():
		state_machine.change_state("DashState")
		return
	
	if not player.is_on_floor():
		state_machine.change_state("FallState")
		return

	player.check_ledge()
	if player.is_on_ledge:
		state_machine.change_state("LedgeState")
		return

	if player.is_on_wall() and not player.is_on_floor():
		state_machine.change_state("WallState")
		return
	return
