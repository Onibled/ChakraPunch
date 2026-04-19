extends ColorRect

func flash():
	modulate.a = 0.6
	await get_tree().create_timer(0.03).timeout
	modulate.a = 0
