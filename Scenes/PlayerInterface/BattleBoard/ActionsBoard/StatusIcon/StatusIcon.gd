extends Control


class_name StatusIcon

onready var sprite_node = $MarginContainer/CenterContainer/Control/Sprite
onready var label_node = $MarginContainer/Control/Label
onready var tooltip_target = $MarginContainer/CenterContainer/Control/Tooltip2D

var status_data : StatusData setget set_status_data

func update():
	sprite_node.texture = status_data.icon
	if status_data.stacks_the_d():
		label_node.text = str(status_data.duration)
	else:
		label_node.text = str(status_data.intensity)
	if label_node.text == "0":
		queue_free()

func set_status_data(value:StatusData):
	status_data = value
	update()
