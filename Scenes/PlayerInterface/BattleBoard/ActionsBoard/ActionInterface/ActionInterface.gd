extends Control


class_name ActionsInterface

var character_data : CharacterData setget set_character_data

func set_character_data(value:CharacterData):
	character_data = value

func add_opening(opportunity:OpportunityData):
	pass

func remove_all_openings():
	pass

func get_player_battle_openings():
	return []

func get_opponent_battle_openings():
	return []

func add_status(status:StatusData):
	pass

func remove_status(status:StatusData):
	pass
