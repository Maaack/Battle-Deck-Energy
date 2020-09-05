extends Node


export(Array, Resource) var levels : Array = []
export(int) var starting_level : int = 0

var current_level : int = 0

func reset():
	current_level = starting_level

func advance():
	current_level += 1

func get_current_level():
	var level_index = current_level % levels.size()
	return levels[level_index]

func get_level_opponents():
	var level : LevelData = get_current_level()
	if level == null:
		return
	return level.opponents
