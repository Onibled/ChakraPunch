extends Node2D
class_name Activatable

signal activated
signal deactivated

@export var starts_active: bool = false

var is_active: bool = false

func _ready():
	if starts_active:
		activate()
	else:
		deactivate()
	return

# Activates the object if not already active
func activate():
	if is_active:
		return

	is_active = true
	_on_activated()
	activated.emit()
	return

# Deactivates the object if not already active
func deactivate():
	if not is_active:
		return

	is_active = false
	_on_deactivated()
	deactivated.emit()
	return

# Change the activation or deactivation based on current status
func toggle():
	if is_active:
		deactivate()
	else:
		activate()
	return

# Determines an operation on activation
func _on_activated():
	pass

# Determines an operation on deactivation
func _on_deactivated():
	pass
