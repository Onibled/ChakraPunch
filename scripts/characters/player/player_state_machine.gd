extends Node
class_name PlayerStateMachine
 
var current_state
var states = {}

func _ready():
	for child in get_children():
		states[child.name] = child
		child.state_machine = self
		child.player = get_parent()
	
	change_state("MoveState")

func change_state(state_name):
	if owner.has_method("force_reset_movement_state"):
		owner.force_reset_movement_state()

	if current_state:
		current_state.exit()
	
	current_state = states[state_name]
	current_state.enter()

func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)
