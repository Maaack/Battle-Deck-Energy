extends CharacterActionsInterface


class_name OpponentActionsInterface

onready var dead_cover = $DeadCover
onready var opponent_opportunities_container = $MarginContainer/MarginContainer/Control/OpponentOpportunitiesContainer

func set_character_data(value:CharacterData):
	.set_character_data(value)
	_update_nickname(character_data.nickname)

func add_opportunity(opportunity:OpportunityData):
	if opportunity in opportunities_map:
		return
	opportunities_map[opportunity] = true
	if opportunity.source == character_data:
		opponent_opportunities_container.add_opportunity(opportunity)
		return opponent_opportunities_container
	else:
		opportunities_container.add_opportunity(opportunity)
		return opportunities_container

func remove_opportunity(opportunity:OpportunityData, erase_flag = true):
	if not opportunity in opportunities_map:
		return
	if opportunity.source == character_data:
		opponent_opportunities_container.remove_opportunity(opportunity)
	else:
		opportunities_container.remove_opportunity(opportunity)
	if erase_flag:
		opportunities_map.erase(opportunity)

func defeat_character():
	.defeat_character()
	dead_cover.show()
