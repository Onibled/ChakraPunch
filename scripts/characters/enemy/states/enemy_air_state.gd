extends StateEnemy

func enter():
	enemy.juggle_count += 1
	enemy.air_time = 0
	return

func update(delta):
	enemy.air_time += delta
	
	var float_factor := 1.0
	
	if enemy.air_time < 0.25:
		float_factor = 0.6
	
	var gravity_multiplier = 1.0 + (enemy.juggle_count * 0.3)
	
	enemy.velocity.y += enemy.gravity * gravity_multiplier * float_factor * delta
	
	#anti infinite combo
	if enemy.juggle_count > enemy.juggle_limit:
		enemy.velocity.y = max(enemy.velocity.y, 250)
	
	# wall splat
	if enemy.is_on_wall() and abs(enemy.velocity.x) > 100:
		state_machine.change_state("WallSplatState")
		return
	
	# landing
	if enemy.is_on_floor():
		state_machine.change_state("IdleState")
		return
	return
	# ground bounce
	if enemy.is_on_floor() and enemy.is_airborne:
		if enemy.velocity.y > 300:
			enemy.velocity.y = -200
		else:
			state_machine.change_state("IdleState")
	
