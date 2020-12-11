extends CharacterActionsInterface


class_name OpponentActionsInterface

onready var dead_cover = $DeadCover
onready var opponent_opportunities_container = $MarginContainer/MarginContainer/Control/OpponentOpportunitiesContainer
onready var opponent_hand_container = $MarginContainer/MarginContainer/Control/OpponentHandContainer/Control
onready var opponent_hand_position = $MarginContainer/MarginContainer/Control/OpponentHandContainer/Control/Position2D

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

func get_reveal_position():
	return opponent_opportunities_container.get_card_parent_position()

func get_reveal_scale():
	return opponent_opportunities_container.rect_scale

func get_reveal_transform():
	var reveal_transform : TransformData = TransformData.new()
	reveal_transform.position = get_reveal_position()
	reveal_transform.scale = get_reveal_scale()
	return reveal_transform

func get_hand_position():
	return opponent_hand_position.global_position

func get_hand_scale():
	return Vector2(1,1) * 0.375

func get_hand_transform():
	var hand_transform : TransformData = TransformData.new()
	hand_transform.position = get_hand_position()
	hand_transform.scale = get_hand_scale()
	return hand_transform

func defeat_character():
	.defeat_character()
	dead_cover.show()
