extends Node


class_name StatusManager

signal gained_status(status)
signal lost_status(status)
signal updated_status(status, delta)

var status_type_map : Dictionary = {}

func get_status_by_type(status_type:String):
	if not status_type in status_type_map:
		return
	return status_type_map[status_type]

func get_manager_status(status:StatusData):
	var status_type : String = status.type_tag
	if status_type in status_type_map:
		return status_type_map[status_type]
	var manager_status : StatusData = status.duplicate()
	manager_status.reset_stack()
	status_type_map[status_type] = manager_status
	emit_signal("gained_status", manager_status)
	return manager_status

func gain_status(status:StatusData):
	var manager_status = get_manager_status(status)
	var stack_delta = status.get_stack_value()
	manager_status.add_to_stack(stack_delta)
	emit_signal("updated_status", manager_status, stack_delta)

func lose_status(status:StatusData):
	var status_type : String = status.type_tag
	if not status_type in status_type_map:
		return
	var manager_status : StatusData = status_type_map[status_type]
	status_type_map.erase(status_type)
	emit_signal("lost_status", manager_status)

func decrement_durations():
	for status in status_type_map.values():
		if status is StatusData:
			if status.has_the_d():
				status.duration -= 1
				# emit_signal("updated_status", status, -1)
				if not status.has_the_d():
					lose_status(status)
				else:
					emit_signal("gained_status", status)
