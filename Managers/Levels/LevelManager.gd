extends Node


export(Array, Resource) var levels : Array = []
export(int) var starting_level : int = 0

var current_level : int = 0

func reset():
	current_level = starting_level

func advance():
	current_level = (current_level + 1) % levels.size()

func get_current_level():
	return levels[current_level]

func get_level_opponents():
	var level : LevelData = get_current_level()
	if level == null:
		return
	return level.opponents
