extends Node


class_name StatusManager

signal status_updated(status, delta)
signal related_status_changed(character, status, delta)

var status_map : Dictionary = {}
var source_related_status_map : Dictionary = {}
var target_related_status_map : Dictionary = {}
var related_status_character_map : Dictionary = {}

func has_statuses():
	return status_map.size() > 0 

func get_status(status_type:String):
	if not status_type in status_map:
		return
	return status_map[status_type]

func get_related_status(status_type : String, related, is_target: bool = true):
	if is_target:
		if not related in source_related_status_map:
			return
		if not status_type in source_related_status_map[related]:
			return
		return source_related_status_map[related][status_type]
	else:
		if not related in target_related_status_map:
			return
		if not status_type in target_related_status_map[related]:
			return
		return target_related_status_map[related][status_type]

func get_manager_status(status:StatusData, is_target: bool = true):
	if status is RelatedStatusData:
		if is_target:
			if status.source in source_related_status_map:
				if status.type_tag in source_related_status_map[status.source]:
					return source_related_status_map[status.source][status.type_tag]
		else:
			if status.target in target_related_status_map:
				if status.type_tag in target_related_status_map[status.target]:
					return target_related_status_map[status.target][status.type_tag]
	elif status.type_tag in status_map:
		return status_map[status.type_tag]
	var new_status : StatusData = status.duplicate()
	new_status.reset_stack()
	if new_status is RelatedStatusData:
		if is_target:
			if not status.source in source_related_status_map:
				source_related_status_map[status.source] = {}
			if not status.type_tag in source_related_status_map[status.source]:
				source_related_status_map[status.source][status.type_tag] = new_status
			related_status_character_map[new_status] = status.source
		else:
			if not status.target in target_related_status_map:
				target_related_status_map[status.target] = {}
			if not status.type_tag in target_related_status_map[status.target]:
				target_related_status_map[status.target][status.type_tag] = new_status
			related_status_character_map[new_status] = status.target
	else:
		status_map[status.type_tag] = new_status
	return new_status

func gain_status(status:StatusData, is_target: bool = true):
	var manager_status = get_manager_status(status, is_target)
	var stack_delta = status.get_stack_value()
	manager_status.add_to_stack(stack_delta)
	emit_signal("status_updated", manager_status.duplicate(), stack_delta)
	if manager_status.get_stack_value() == 0:
		lose_status(status)

func lose_status(status:StatusData):
	if not status in status_map:
		return
	if status is RelatedStatusData:
		if status.source in source_related_status_map and status.type_tag in source_related_status_map[status.source]:
			var related_status = source_related_status_map[status.source][status.type_tag]
			related_status_character_map.erase(related_status)
			source_related_status_map[status.source].erase(status.type_tag)
		if status.target in target_related_status_map and status.type_tag in target_related_status_map[status.target]:
			var related_status = target_related_status_map[status.target][status.type_tag]
			related_status_character_map.erase(related_status)
			target_related_status_map[status.target].erase(status.type_tag)
	else:
		status_map.erase(status.type_tag)

func _duplicate_relating_status(status:RelatedStatusData):
	var related_status : RelatedStatusData = status.relating_status.duplicate()
	related_status.set_stack_value(status.get_stack_value())
	related_status.relating_status = status
	return related_status

func decrement_duration(status:StatusData):
	var delta : int = -1
	if status.has_the_d():
		status.duration += delta
		if status.stacks_the_d():
			emit_signal("status_updated", status.duplicate(), delta)
			if status is RelatedStatusData:
				var related_character = related_status_character_map[status]
				var related_status : RelatedStatusData = _duplicate_relating_status(status)
				related_status.set_stack_value(delta)
				emit_signal("related_status_changed", related_character, related_status, delta)
		else:
			var diff : int = -(status.get_stack_value())
			status.reset_stack()
			emit_signal("status_updated", status.duplicate(), diff)
			if status is RelatedStatusData:
				var related_character = related_status_character_map[status]
				var related_status : RelatedStatusData = _duplicate_relating_status(status)
				related_status.set_stack_value(diff)
				emit_signal("related_status_changed", related_character, related_status, diff)
		if not status.has_the_d():
			lose_status(status)

func decrement_durations(status_type:StatusData.StatusType):
	var statuses : Array = status_map.values()
	for status in statuses:
		if status is StatusData:
			if status.status_type != status_type:
				continue
			if status.get_stack_value() == 0:
				lose_status(status)
				continue
			decrement_duration(status)
