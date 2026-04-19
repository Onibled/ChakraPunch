extends StatePlayer

var stun_time: float = 0.0
var duration: float = 0.3

func enter():
	stun_time = 0.0
	return

func update(delta):
	stun_time += delta
	
	player.handle_gravity(delta)
	player.move_and_slide()
	
	# WALL SPLAT CHECK 🔥
	if player.is_on_wall() and abs(player.velocity.x) > 200:
		state_machine.change_state("WallSplatState")
		return
	
	if stun_time >= duration:
		if player.is_on_floor():
			state_machine.change_state("MoveState")
		else:
			state_machine.change_state("FallState")
	return
