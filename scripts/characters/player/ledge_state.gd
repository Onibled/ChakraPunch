extends StatePlayer

func enter():
	player.anim.play("ledge")
	player.velocity = Vector2.ZERO
	return

func update(delta):
	player.climb_ledge()
	state_machine.change_state("MoveState")
	return
	
	player.velocity = Vector2.ZERO
	
	if player.input_buffer.consume("jump"):
		player.climb_ledge()
		state_machine.change_state("MoveState")
		return
	
	if Input.is_action_pressed("ui_down"):
		player.drop_ledge()
		state_machine.change_state("FallState")
		return
	
	if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
		player.jump_from_ledge()
		state_machine.change_state("JumpState")
		return
	return
