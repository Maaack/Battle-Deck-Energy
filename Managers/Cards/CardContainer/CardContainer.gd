extends Control


class_name CardContainer

onready var card_center_position = $CenterContainer/Control/CardCenter

func get_card_global_position():
	return card_center_position.global_position
