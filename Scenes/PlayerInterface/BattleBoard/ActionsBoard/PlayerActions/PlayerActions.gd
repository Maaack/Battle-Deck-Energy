extends Control


class_name PlayerActionsInterface

onready var active_opening_manager = $MarginContainer/VBoxContainer/MarginContainer/OpeningsContainer/Active
onready var passive_opening_manager = $MarginContainer/VBoxContainer/MarginContainer/OpeningsContainer/Passive

func add_active_opening(opportunity:OpportunityData):
	return active_opening_manager.add_opening(opportunity)

func sub_active_opening():
	active_opening_manager.sub_opening()

func add_passive_opening(opportunity:OpportunityData):
	return passive_opening_manager.add_opening(opportunity)

func sub_passive_opening():
	passive_opening_manager.sub_opening()

func remove_all_openings():
	active_opening_manager.remove_all_openings()
	passive_opening_manager.remove_all_openings()

func get_player_battle_openings():
	var openings : Array = active_opening_manager.get_battle_openings()
	openings += passive_opening_manager.get_battle_openings()
	return openings
