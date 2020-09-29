extends HBoxContainer


signal status_inspected(status_icon)
signal status_forgotten(status_icon)

onready var status_scene = preload("res://Scenes/PlayerInterface/BattleBoard/ActionsBoard/StatusIcon/StatusIcon.tscn")

var status_map : Dictionary = {}

func get_status_icon(status:StatusData):
	if status.type_tag in status_map:
		return status_map[status.type_tag]
	var status_instance = status_scene.instance()
	add_child(status_instance)
	status_instance.status_data = status
	status_instance.connect("mouse_entered", self, "_on_StatusIcon_mouse_entered", [status_instance])
	status_instance.connect("mouse_exited", self, "_on_StatusIcon_mouse_exited", [status_instance])
	status_map[status.type_tag] = status_instance
	return status_instance

func add_status(status:StatusData):
	var status_icon = get_status_icon(status)
	status_icon.status_data = status

func remove_status(status:StatusData):
	if not status.type_tag in status_map:
		return
	var status_instance = status_map[status.type_tag]
	status_instance.queue_free()
	status_map.erase(status.type_tag)

func _on_StatusIcon_mouse_entered(status_icon:StatusIcon):
	emit_signal("status_inspected", status_icon)

func _on_StatusIcon_mouse_exited(status_icon:StatusIcon):
	emit_signal("status_forgotten", status_icon)
