extends HBoxContainer


onready var status_scene = preload("res://Scenes/PlayerInterface/BattleBoard/ActionsBoard/StatusIcon/StatusIcon.tscn")

var statuses : Array = []
var status_type_map : Dictionary = {}

func get_status_icon(status_type:String, status_icon:Texture):
	if status_type in status_type_map:
		return status_type_map[status_type]
	var status_instance = status_scene.instance()
	add_child(status_instance)
	status_instance.icon = status_icon
	status_type_map[status_type] = status_instance
	return status_instance

func add_status(status:StatusData):
	var status_icon = get_status_icon(status.type_tag, status.icon)
	status_icon.integer += status.intensity
