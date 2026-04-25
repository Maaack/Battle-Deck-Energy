@tool
extends Node


@export var levels : Array = [] # (Array, Resource)
@export var paths : Array[String]
@export var starting_level: int = 0

var current_level : int = 0

func reset():
	current_level = starting_level
	paths.clear()
	for level in levels:
		if level is Resource:
			paths.append(level.resource_path)

func advance():
	current_level += 1

func get_current_level():
	var level_index = current_level % paths.size()
	return load(paths[level_index])

func _ready():
	reset()
