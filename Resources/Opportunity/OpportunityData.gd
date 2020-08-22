extends Resource


class_name OpportunityData

const NO_TYPE = -1

var source : CharacterData
var target : CharacterData
var opp_type : int = NO_TYPE
var card_data = null setget set_card
var prs = PRSData.new()

func is_open():
	return not is_instance_valid(card_data)

func set_card(value:CardData):
	if is_open():
		card_data = value

func clear():
	card_data = null