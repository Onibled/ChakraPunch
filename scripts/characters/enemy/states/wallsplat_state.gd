extends StateEnemy

var timer: float = 0.0
var duration: float = 0.4

func enter():
	timer = 0.0
	
	# blocca il enemy sul muro
	enemy.velocity = Vector2.ZERO
	return

func update(delta):
	timer += delta
	
	# effetto "incollato al muro"
	enemy.velocity = Vector2.ZERO
	
	if timer >= duration:
		state_machine.change_state("FallState")
	return
