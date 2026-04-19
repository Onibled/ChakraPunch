extends Node2D

var lifetime := 0.2

func _ready():
	$AnimationPlayer.play("impact")
	
	await get_tree().create_timer(lifetime).timeout
	queue_free()
