extends Node2D

func _ready():
	var player = $Player
	var hud = $PlayerHUD
	
	hud.set_player(player)
	player.add_chakra(0)
