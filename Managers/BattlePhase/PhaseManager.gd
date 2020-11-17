extends Node


const INIT_PHASE = -1

export(int) var starting_phase_tier = INIT_PHASE
onready var _phase_tier : int = starting_phase_tier
var phase_scene = preload("res://Managers/BattlePhase/Phase.tscn")
var current_phase

func add_phase(phase_name : String):
	var phase_instance = phase_scene.instance()
	phase_instance.name = phase_name
	add_child(phase_instance)
	return phase_instance

func get_current_phase():
	if _phase_tier == INIT_PHASE:
		return
	var child_count : int = get_child_count()
	if child_count > 0 and _phase_tier <= child_count - 1:
		return get_children()[_phase_tier]

func enter_phase():
	current_phase = get_current_phase()
	if current_phase is Phase:
		current_phase.enter()

func exit_phase():
	current_phase = get_current_phase()
	if current_phase is Phase:
		current_phase.exit()

func advance():
	exit_phase()
	var next_phase = _phase_tier + 1
	var child_count = get_child_count()
	if child_count == 0:
		print("Error: Advancing battle phases without children.")
		return
	_phase_tier = next_phase % child_count
	var phase_node = get_children()[_phase_tier]
	print("Phase `%s`" % phase_node.name)
	enter_phase()
	return _phase_tier

func move_phase(phase_name : String, new_index : int):
	for child in get_children():
		if child.name == phase_name:
			move_child(child, new_index)
			return
	print("Warning: No phase by name `%s` found" % phase_name)
