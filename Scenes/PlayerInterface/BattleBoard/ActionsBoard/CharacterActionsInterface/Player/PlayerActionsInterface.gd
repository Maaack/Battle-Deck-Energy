extends CharacterActionsInterface


class_name PlayerActionsInterface

const PLAYER_DEFAULT_NICKNAME = "You"

onready var active_opening_container = $MarginContainer/VBoxContainer/OpeningsMargin/OpeningsContainer/Active
onready var passive_opening_container = $MarginContainer/VBoxContainer/OpeningsMargin/OpeningsContainer/Passive

func _update_nickname(nickname:String = PLAYER_DEFAULT_NICKNAME):
	._update_nickname(nickname)

func add_opening(opportunity:OpportunityData):
	return _add_opening(opportunity, active_opening_container)

func get_player_battle_openings():
	return get_source_battle_openings()
