extends StatePlayer

func enter():
	#player.anim.play("idle")
	pass

func update(delta):
	player.handle_movement(delta)
	
	if abs(player.velocity.x) > 40:
		player.anim.play("run")
	else:
		player.anim.play("idle")
	
	if Input.is_action_just_pressed("jump"):
		if player.is_on_floor():
			state_machine.change_state("JumpState")
			return
			
	if Input.is_action_pressed("meditate") and player.is_on_floor():
		state_machine.change_state("MeditateState")
		return
	
	if not player.is_on_floor():
		state_machine.change_state("FallState")
		return
	
	if player.is_on_wall() and not player.is_on_floor():
		state_machine.change_state("WallState")
		return
	
	player.check_ledge()
	if player.is_on_ledge:
		state_machine.change_state("LedgeState")
		return
	return
