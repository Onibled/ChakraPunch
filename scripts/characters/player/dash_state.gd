extends StatePlayer

func enter():
	if not player.can_dash():
		state_machine.change_state("MoveState")
		return
	
	player.start_dash()
	return

func update(delta):
	player.update_dash(delta)
	
	# -------------------------------------------------
	# CANCEL (OPZIONALE)
	# -------------------------------------------------
	
	if Input.is_action_just_pressed("light_attack"):
		state_machine.change_state("AttackState")
		exit()
		return
		
	if player.input_buffer.consume("jump"):
		state_machine.change_state("JumpState")
		exit()
		return
		
	# -------------------------------------------------
	# FINE DASH
	# -------------------------------------------------
	
	if not player.is_dashing:
		if player.is_on_floor():
			state_machine.change_state("MoveState")
		else:
			state_machine.change_state("FallState")
	return

func exit():
	player.is_dashing = false
	return
