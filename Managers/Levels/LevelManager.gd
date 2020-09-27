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
	var level_list = levels[level_index]
	if level_list is WeightedDataList:
		return level_list.get_random_data()
	return level_list

func get_level_opponents():
	var level : LevelData = get_current_level()
	if level == null:
		return
	return level.opponents
