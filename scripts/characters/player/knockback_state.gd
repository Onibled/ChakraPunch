extends StatePlayer

var stun_time := 0.3

func enter():
	stun_time = 0.3
	player.anim.play("hit")

func update(delta):
	stun_time -= delta
	
	# gravità
	player.velocity.y += player.gravity * delta
	
	player.move_and_slide()
	
	if stun_time <= 0:
		state_machine.change_state("MoveState")
