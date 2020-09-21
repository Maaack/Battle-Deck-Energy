extends HBoxContainer


onready var status_scene = preload("res://Scenes/PlayerInterface/BattleBoard/ActionsBoard/StatusIcon/StatusIcon.tscn")

var status_map : Dictionary = {}

func get_status_icon(status:StatusData):
	if status.type_tag in status_map:
		return status_map[status.type_tag]
	var status_instance = status_scene.instance()
	add_child(status_instance)
	status_instance.icon = status.icon
	status_map[status.type_tag] = status_instance
	return status_instance

func add_status(status:StatusData):
	var status_icon = get_status_icon(status)
	if status.stacks_the_d():
		status_icon.integer = status.duration
	else:
		status_icon.integer = status.intensity
	if status_icon.integer == 0:
		remove_status(status)

func remove_status(status:StatusData):
	if not status.type_tag in status_map:
		return
	var status_instance = status_map[status.type_tag]
	status_instance.queue_free()
	status_map.erase(status.type_tag)
