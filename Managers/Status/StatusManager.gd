extends Node


class_name StatusManager

signal status_updated(status, delta)

enum CycleMode{NONE, START_1, START_2, START_3, END}

var status_map : Dictionary = {}
var status_cycle_map : Dictionary = {}
var related_status_source_map : Dictionary = {}
var related_status_target_map : Dictionary = {}

func has_statuses():
	return status_map.size() > 0

func get_status(status_type:String):
	if not status_type in status_map:
		return
	return status_map[status_type]

func get_related_status(status_type : String, related, is_target: bool = true):
	if is_target:
		if not related in related_status_source_map:
			return
		if not status_type in related_status_source_map[related]:
			return
		return related_status_source_map[related][status_type]
	else:
		if not related in related_status_target_map:
			return
		if not status_type in related_status_target_map[related]:
			return
		return related_status_target_map[related][status_type]

func get_manager_status(status:StatusData, cycle_mode:int = CycleMode.NONE, is_target: bool = true):
	var status_type : String = status.type_tag
	if status is RelatedStatusData:
		if is_target:
			if status.source in related_status_source_map:
				if status_type in related_status_source_map[status.source]:
					return related_status_source_map[status.source][status_type]
		else:
			if status.target in related_status_target_map:
				if status_type in related_status_target_map[status.target]:
					return related_status_target_map[status.target][status_type]
	elif status_type in status_map:
		return status_map[status_type]
	var new_status : StatusData = status.duplicate()
	new_status.reset_stack()
	status_cycle_map[new_status] = cycle_mode
	if new_status is RelatedStatusData:
		if is_target:
			if not status.source in related_status_source_map:
				related_status_source_map[status.source] = {}
			if not status_type in related_status_source_map[status.source]:
				related_status_source_map[status.source][status_type] = new_status
		else:
			if not status.target in related_status_target_map:
				related_status_target_map[status.target] = {}
			if not status_type in related_status_target_map[status.target]:
				related_status_target_map[status.target][status_type] = new_status
	else:
		status_map[status_type] = new_status
	return new_status

func gain_status(status:StatusData, cycle_mode:int = CycleMode.NONE, is_target: bool = true):
	var manager_status = get_manager_status(status, cycle_mode, is_target)
	var stack_delta = status.get_stack_value()
	manager_status.add_to_stack(stack_delta)
	emit_signal("status_updated", manager_status.duplicate(), stack_delta)
	if manager_status.get_stack_value() == 0:
		lose_status(status)

func lose_status(status:StatusData):
	if not status in status_cycle_map:
		return
	status_cycle_map.erase(status)
	var status_type : String = status.type_tag
	if status is RelatedStatusData:
		if status.source in related_status_source_map:
			related_status_source_map[status.source].erase(status_type)
		if status.target in related_status_target_map:
			related_status_target_map[status.target].erase(status_type)
	else:
		status_map.erase(status_type)

func decrement_duration(status:StatusData):
	if status.has_the_d():
		status.duration -= 1
		if status.stacks_the_d():
			emit_signal("status_updated", status.duplicate(), -1)
		else:
			var diff : int = -(status.get_stack_value())
			status.reset_stack()
			emit_signal("status_updated", status.duplicate(), diff)
		if not status.has_the_d():
			lose_status(status)

func decrement_durations(cycle_mode:int = CycleMode.START_1):
	var local_status_cycle_map : Dictionary = status_cycle_map.duplicate()
	for status in local_status_cycle_map:
		if local_status_cycle_map[status] != cycle_mode:
			continue
		if status is StatusData:
			if status.get_stack_value() == 0:
				lose_status(status)
				continue
			decrement_duration(status)
