extends StatePlayer

var vault_speed := 260
var vault_height := -150

func enter():
	player.anim.play("vault")
	
	# movimento iniziale
	player.velocity = Vector2.ZERO
	
	# spinta controllata
	player.velocity.x = player.facing_direction * vault_speed
	player.velocity.y = vault_height
	return

# ---------------------------------------------------------

func physics_update(delta):
	
	# piccolo follow
	player.velocity.x = move_toward(
		player.velocity.x,
		player.facing_direction * vault_speed,
		600 * delta
	)
	
	# uscita stato
	if player.is_on_floor():
		state_machine.change_state("MoveState")
	return
