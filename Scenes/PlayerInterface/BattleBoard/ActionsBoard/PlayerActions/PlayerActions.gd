extends ActionsInterface


class_name PlayerActionsInterface

onready var active_opening_manager = $MarginContainer/VBoxContainer/OpeningsMargin/OpeningsContainer/Active
onready var passive_opening_manager = $MarginContainer/VBoxContainer/OpeningsMargin/OpeningsContainer/Passive
onready var status_icon_manager = $MarginContainer/VBoxContainer/StatusesMargin/StatusIconManager

func add_opening(opportunity:OpportunityData):
	return active_opening_manager.add_opening(opportunity)

func remove_all_openings():
	active_opening_manager.remove_all_openings()
	passive_opening_manager.remove_all_openings()

func get_player_battle_openings():
	var openings : Array = active_opening_manager.get_battle_openings()
	openings += passive_opening_manager.get_battle_openings()
	return openings

func add_status(status:StatusData):
	status_icon_manager.add_status(status)
