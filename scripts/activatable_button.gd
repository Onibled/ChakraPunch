extends Node2D

@export var target: Activatable

func interact():
	target.activate()
