extends ActionsInterface


class_name PlayerActionsInterface

onready var active_opening_container = $MarginContainer/VBoxContainer/OpeningsMargin/OpeningsContainer/Active
onready var passive_opening_container = $MarginContainer/VBoxContainer/OpeningsMargin/OpeningsContainer/Passive
onready var status_icon_manager = $MarginContainer/VBoxContainer/StatusesMargin/StatusIconManager

func add_opening(opportunity:OpportunityData):
	return _add_opening(opportunity, active_opening_container)

func get_player_battle_openings():
	return get_source_battle_openings()

func add_status(status:StatusData):
	status_icon_manager.add_status(status)

func remove_status(status:StatusData):
	status_icon_manager.remove_status(status)
