extends Control


class_name CardContainer

onready var card_center_position = $CenterContainer/Control/CardCenter
onready var centered_control =  $CenterContainer/Control

func get_card_parent_position():
	return get_rect().position + centered_control.get_rect().position
