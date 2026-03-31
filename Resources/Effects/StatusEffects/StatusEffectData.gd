extends EffectData


class_name StatusEffectData

@export var starting_statuses : Array = []: set = set_starting_statuses

var statuses = []

func _reset_statuses():
	statuses = starting_statuses.duplicate()

func reset():
	_reset_statuses()

func set_starting_statuses(value:Array):
	starting_statuses = value
	_reset_statuses()
