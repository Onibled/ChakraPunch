extends Node
class_name EnemyStateMachine

var current_state
var states = {}

func _ready():
	for child in get_children():
		states[child.name] = child
		child.state_machine = self
		child.enemy = get_parent()
	
	change_state("IdleState")

func change_state(state_name):
	if current_state:
		current_state.exit()
	
	current_state = states[state_name]
	current_state.enter()

func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)
