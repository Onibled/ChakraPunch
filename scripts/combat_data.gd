extends Node

enum ForceLevel {
	NONE,
	LIGHT,
	MEDIUM,
	STRONG
}

const HORIZONTAL_FORCE = {
	ForceLevel.NONE: 0,
	ForceLevel.LIGHT: 5,
	ForceLevel.MEDIUM: 200,
	ForceLevel.STRONG: 400
}

const VERTICAL_FORCE = {
	ForceLevel.NONE: 0,
	ForceLevel.LIGHT: -100,
	ForceLevel.MEDIUM: -300,
	ForceLevel.STRONG: -500
}

static func get_horizontal_force(level):
	return HORIZONTAL_FORCE.get(level, 0)

static func get_vertical_force(level):
	return VERTICAL_FORCE.get(level, 0)
