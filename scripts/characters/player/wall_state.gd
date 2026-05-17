extends StatePlayer

func enter():
	player.anim.play("wall")
	return
	
func update(delta):
	player.handle_wall_slide()
	
	if player.input_buffer.consume("jump"):
		var dir = player.get_wall_normal().x
		state_machine.change_state("JumpState")
		player.velocity.x = dir * player.wall_jump_x
		player.velocity.y = player.wall_jump_y
		return
		
	if player.input_direction != 0 && player.input_direction != player.facing_direction:
		state_machine.change_state("MoveState")
		return
	
	if player.is_on_floor():
		state_machine.change_state("MoveState")
		return
	
	if not player.is_on_wall():
		state_machine.change_state("FallState")
		return
	
	return
