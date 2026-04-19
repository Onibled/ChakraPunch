extends StateEnemy

var timer: float = 0.4

func enter():
	timer = 0.4
	enemy.velocity = Vector2.ZERO
	return

func update(delta):
	timer -= delta
	
	enemy.velocity = Vector2.ZERO
	
	if timer <= 0:
		state_machine.change_state("IdleState")
	return
