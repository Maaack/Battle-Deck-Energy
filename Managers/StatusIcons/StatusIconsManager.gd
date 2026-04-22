extends HBoxContainer

@onready var status_scene = preload("res://Scenes/PlayerInterface/BattleBoard/ActionsBoard/StatusIcon/StatusIcon.tscn")

var status_map : Dictionary = {}

func get_status_icon(status:StatusData):
	if status.type_tag in status_map:
		return status_map[status.type_tag]
	var status_instance = status_scene.instantiate()
	add_child(status_instance)
	status_instance.status_data = status
	status_instance.connect("mouse_entered", Callable(self, "_on_StatusIcon_mouse_entered").bind(status_instance))
	status_instance.connect("mouse_exited", Callable(self, "_on_StatusIcon_mouse_exited").bind(status_instance))
	status_instance.connect("tree_exited", Callable(self, "_on_StatusIcon_tree_exited").bind(status_instance))
	status_map[status.type_tag] = status_instance
	return status_instance

func update_status(status:StatusData):
	var status_icon = get_status_icon(status)
	status_icon.status_data = status

func _on_StatusIcon_tree_exited(status_icon:StatusIcon):
	status_map.erase(status_icon.status_data.type_tag)

func _on_StatusIcon_mouse_entered(status_icon:StatusIcon):
	EventBus.status_inspected.emit(status_icon)

func _on_StatusIcon_mouse_exited(status_icon:StatusIcon):
	EventBus.status_restored.emit(status_icon)
