extends Area2D

func _on_body_entered(body):
	if body.is_in_group("player"):
		var cam = get_tree().get_first_node_in_group("camera")
		if cam:
			cam.unlock()
