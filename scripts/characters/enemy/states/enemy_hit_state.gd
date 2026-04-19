extends StateEnemy

var stun_time: float = 0.2

func enter():
	# puoi leggere da enemy.attack_data se vuoi
	stun_time = 0.2
	return

func update(delta):
	stun_time -= delta
	
	# friction orizzontale
	if not enemy.is_knockback:
		enemy.velocity.x = move_toward(enemy.velocity.x, 0, 200 * delta)
	
	# gravità
	enemy.velocity.y += enemy.gravity * delta
	
	if stun_time <= 0:
		state_machine.change_state("IdleState")
	return
