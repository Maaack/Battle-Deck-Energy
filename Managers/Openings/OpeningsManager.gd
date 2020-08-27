extends HBoxContainer


onready var opening_scene = preload("res://Managers/Openings/Opening.tscn")

var openings_map : Dictionary = {}

func add_opening(opportunity:OpportunityData):
	var opening_instance = opening_scene.instance()
	add_child(opening_instance)
	opening_instance.opportunity_data = opportunity
	openings_map[opportunity] = opening_instance
	return opening_instance

func sub_opening():
	var last_node = get_children().back()
	if is_instance_valid(last_node):
		remove_child(last_node)

func get_battle_openings():
	var battle_openings : Array = []
	for child in get_children():
		if child is BattleOpening:
			if child.is_open():
				battle_openings.append(child)
	return battle_openings

func remove_all_openings():
	for child in get_children():
		remove_child(child)
		child.queue_free()
