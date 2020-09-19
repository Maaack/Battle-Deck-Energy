extends Control


class_name ActionsInterface

var character_data : CharacterData setget set_character_data
var opportunities_map : Dictionary = {}

func set_character_data(value:CharacterData):
	character_data = value

func add_opportunity(opportunity:OpportunityData):
	pass

func remove_opportunity(opportunity:OpportunityData, erase_flag = true):
	pass

func add_status(status:StatusData):
	pass

func remove_status(status:StatusData):
	pass
