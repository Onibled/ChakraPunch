extends StatePlayer

func enter():
	player.anim.play("jump")
	player.velocity.y = player.jump_force

func update(delta):
	player.handle_gravity(delta)
	player.handle_movement(delta)
	player.handle_jump()
	
	if player.velocity.y > 0:
		state_machine.change_state("FallState")
		return
	
	player.move_and_slide()
	return
