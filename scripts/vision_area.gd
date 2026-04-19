# VisionArea.gd
extends Area2D

signal player_detected(player)
signal player_lost()

var player_in_range = null

func _ready():
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)

func _on_enter(body):
	if body.is_in_group("player"):
		player_in_range = body
		emit_signal("player_detected", body)

func _on_exit(body):
	if body == player_in_range:
		player_in_range = null
		emit_signal("player_lost")
