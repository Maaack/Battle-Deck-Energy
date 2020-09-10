extends CharacterActionsInterface


class_name OpponentActionsInterface

onready var opponent_opening_container = $MarginContainer/VBoxContainer/OpeningsMargin/OpeningsContainer/Opponents
onready var player_opening_container = $MarginContainer/VBoxContainer/OpeningsMargin/OpeningsContainer/Players
onready var dead_cover = $DeadCover

func set_character_data(value:CharacterData):
	.set_character_data(value)
	if character_data is OpponentCharacterData:
		_update_nickname(character_data.nickname)
		
func add_opening(opportunity:OpportunityData):
	var container : Node
	if opportunity.source == character_data:
		container = opponent_opening_container
	elif opportunity.target == character_data:
		container = player_opening_container
	return _add_opening(opportunity, container)

func get_player_battle_openings():
	return get_non_source_battle_openings()

func get_opponent_battle_openings():
	return get_source_battle_openings()

func defeat_character():
	.defeat_character()
	dead_cover.show()
