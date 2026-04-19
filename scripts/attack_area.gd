# AttackArea.gd
extends Area2D

signal player_in_attack_range(player)
signal player_out_attack_range()

var target = null

func _ready():
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)
	return

func _on_enter(body):
	if body.is_in_group("player"):
		target = body
		emit_signal("player_in_attack_range", body)
	return

func _on_exit(body):
	if body == target:
		target = null
		emit_signal("player_out_attack_range")
	return
