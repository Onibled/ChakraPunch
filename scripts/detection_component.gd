extends Node

signal player_detected(player)
signal player_lost
signal player_in_range(player)
signal player_out_range

@export var vision_area: Area2D
@export var attack_area: Area2D

func _ready():
	if vision_area:
		vision_area.body_entered.connect(_on_detect)
		vision_area.body_exited.connect(_on_lost)
	
	if attack_area:
		attack_area.body_entered.connect(_on_attack_enter)
		attack_area.body_exited.connect(_on_attack_exit)

func _on_detect(body):
	if body.is_in_group("player"):
		player_detected.emit(body)

func _on_lost(body):
	if body.is_in_group("player"):
		player_lost.emit()

func _on_attack_enter(body):
	if body.is_in_group("player"):
		player_in_range.emit(body)

func _on_attack_exit(body):
	if body.is_in_group("player"):
		player_out_range.emit()
