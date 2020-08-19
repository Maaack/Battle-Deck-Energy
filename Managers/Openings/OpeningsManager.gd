extends HBoxContainer


onready var opening_scene = preload("res://Managers/Openings/Opening.tscn")

func add_opening():
	var opening_instance = opening_scene.instance()
	add_child(opening_instance)

func sub_opening():
	var last_node = get_children().back()
	if is_instance_valid(last_node):
		remove_child(last_node)

func get_opening_positions():
	var openings : Array = []
	for child in get_children():
		if child.has_method("get_opening_global_position"):
			openings.append(child.get_opening_global_position())
	return openings
