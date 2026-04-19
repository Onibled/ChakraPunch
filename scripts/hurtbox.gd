extends Area2D

func take_hit(damage, knockback):
	var owner = get_parent()
	if owner.has_method("apply_knockback"):
		owner.apply_knockback(damage, knockback)
