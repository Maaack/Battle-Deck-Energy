extends Resource


class_name OpportunityData

var source : CharacterData
var target : CharacterData
var type : int = CardData.CardType.NONE
var card_data = null setget set_card
var transform = TransformData.new()

func _to_string():
	return "OpportunityData:%d" % get_instance_id()

func is_open():
	return not is_instance_valid(card_data)

func set_card(value:CardData):
	if is_open():
		card_data = value

func clear():
	card_data = null
