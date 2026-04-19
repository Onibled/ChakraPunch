extends Condition
class_name ChakraCondition

@export var required_chakra: int = 100

func is_met() -> bool:
	return GameState.player_chakra >= required_chakra
