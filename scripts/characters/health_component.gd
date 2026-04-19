extends Node
class_name HealthComponent

@export var max_health: int = 100
var health: int

@export var invincible: bool = false

#region Signals

signal health_changed(current)
signal damaged(amount)
signal died

#endregion

func _ready():
	health = max_health
	health_changed.emit(health)
	return

func damage(amount: int):
	if invincible:
		return
	
	health = max(health - amount, 0)
	
	damaged.emit(amount)
	health_changed.emit(health)
	
	if health <= 0:
		died.emit()
	return

func heal(amount: int):
	health = min(health + amount, max_health)
	health_changed.emit(health)
	return

func set_health(value: int):
	health = clamp(value, 0, max_health)
	health_changed.emit(health)
	return

# Set max health and heals max
func set_max_health(value: int):
	max_health = value
	heal(value)
	return
