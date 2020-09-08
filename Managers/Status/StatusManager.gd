extends Node


class_name StatusManager

signal gained_status(status)
signal lost_status(status)

var status_type_map : Dictionary = {}

func get_status_by_type(status_type:String):
	if not status_type in status_type_map:
		return
	return status_type_map[status_type]

func get_manager_status(status:StatusData):
	var status_type : String = status.type_tag
	var manager_status : StatusData
	if status_type in status_type_map:
		manager_status = status_type_map[status_type]
		if manager_status.stacks_the_d():
			manager_status.duration += status.duration
		else:
			manager_status.intensity += status.intensity
	else:
		manager_status = status.duplicate()
		status_type_map[status_type] = manager_status
	return manager_status

func gain_status(status:StatusData):
	var manager_status = get_manager_status(status)
	emit_signal("gained_status", manager_status)

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
				print("status %s has the d" % status)
				status.duration -= 1
				if not status.has_the_d():
					print("status %s lost the d" % status)
					lose_status(status)
