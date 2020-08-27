extends Control


onready var label_node = $Panel/Label

var allowed_types : Array = [] setget set_allowed_types

func _update_label():
	var new_label : String = ""
	var prepend_string = ""
	for type_string in allowed_types:
		new_label += prepend_string + type_string
		prepend_string = " / "
	label_node.text = new_label

func set_allowed_types(values:Array):
	allowed_types = values
	_update_label()
