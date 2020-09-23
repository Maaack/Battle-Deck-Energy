extends Node


class_name StatusManager

signal updated_status(status, delta)

enum CycleMode{NONE,START,END}

var status_type_map : Dictionary = {}
var status_cycle_map : Dictionary = {}

func get_status_by_type(status_type:String):
	if not status_type in status_type_map:
		return
	return status_type_map[status_type]

func get_local_status(status:StatusData, cycle_mode:int = CycleMode.NONE):
	var status_type : String = status.type_tag
	if status_type in status_type_map:
		return status_type_map[status_type]
	var manager_status : StatusData = status.duplicate()
	manager_status.reset_stack()
	status_type_map[status_type] = manager_status
	status_cycle_map[status_type] = cycle_mode
	return manager_status

func gain_status(status:StatusData, cycle_mode:int = CycleMode.NONE):
	var local_status = get_local_status(status, cycle_mode)
	var stack_delta = status.get_stack_value()
	local_status.add_to_stack(stack_delta)
	emit_signal("updated_status", local_status.duplicate(), stack_delta)

func lose_status(status:StatusData):
	var status_type : String = status.type_tag
	if not status_type in status_type_map:
		return
	status_type_map.erase(status_type)
	status_cycle_map.erase(status_type)

func decrement_duration(status:StatusData):
	if status.has_the_d():
		status.duration -= 1
		if status.stacks_the_d():
			emit_signal("updated_status", status.duplicate(), -1)
		elif not status.has_the_d():
			var diff : int = -(status.get_stack_value())
			status.reset_stack()
			emit_signal("updated_status", status.duplicate(), diff)
		if not status.has_the_d():
			lose_status(status)

func decrement_durations(cycle_mode:int = CycleMode.START):
	var local_status_cycle_map : Dictionary = status_cycle_map.duplicate()
	for status_type in local_status_cycle_map:
		if local_status_cycle_map[status_type] != cycle_mode:
			continue
		var status : StatusData = status_type_map[status_type]
		if not is_instance_valid(status):
			continue
		decrement_duration(status)
