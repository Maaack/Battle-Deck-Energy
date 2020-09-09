extends Control


class_name ActionsInterface

onready var opening_scene = preload("res://Managers/Openings/Opening.tscn")

var character_data : CharacterData setget set_character_data
var opportunities_map : Dictionary = {}

func set_character_data(value:CharacterData):
	character_data = value

func _add_opening(opportunity:OpportunityData, parent = null):
	var opening_instance = opening_scene.instance()
	if parent == null:
		parent = self
	parent.add_child(opening_instance)
	opening_instance.opportunity_data = opportunity
	if not opportunity in opportunities_map:
		opportunities_map[opportunity] = opening_instance
	return opening_instance

func add_opening(opportunity):
	return _add_opening(opportunity)

func remove_opening(opportunity:OpportunityData):
	if not opportunity in opportunities_map:
		return
	var opening : BattleOpening = opportunities_map[opportunity]
	if is_instance_valid(opening):
		opening.queue_free()
	opportunities_map.erase(opportunity)

func remove_all_openings():
	for opening in opportunities_map.values():
		if opening is BattleOpening:
			opening.queue_free()
	opportunities_map.clear()

func get_source_battle_openings():
	var source_openings : Array = []
	for opportunity in opportunities_map:
		if opportunity is OpportunityData:
			if opportunity.source == character_data:
				var opening : BattleOpening = opportunities_map[opportunity]
				source_openings.append(opening)
	return source_openings

func get_non_source_battle_openings():
	var target_openings : Array = []
	for opportunity in opportunities_map:
		if opportunity is OpportunityData:
			if opportunity.source != character_data:
				var opening : BattleOpening = opportunities_map[opportunity]
				target_openings.append(opening)
	return target_openings

func get_player_battle_openings():
	return []

func get_opponent_battle_openings():
	return []

func add_status(status:StatusData):
	pass

func remove_status(status:StatusData):
	pass
