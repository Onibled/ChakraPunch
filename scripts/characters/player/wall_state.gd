extends StatePlayer

func enter():
	player.anim.play("wall")
	return
	
func update(delta):
	player.handle_gravity(delta)
	player.handle_wall_slide()
	
	if Input.is_action_just_pressed("jump"):
		var dir = player.get_wall_normal().x
		player.velocity.x = dir * player.wall_jump_x
		player.velocity.y = player.wall_jump_y
		state_machine.change_state("JumpState")
		return
	
	if player.is_on_floor():
		state_machine.change_state("MoveState")
		return
	
	if not player.is_on_wall():
		state_machine.change_state("FallState")
		return
	
	player.move_and_slide()
	return
