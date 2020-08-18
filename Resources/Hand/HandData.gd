extends Resource


class_name HandData

var cards = []

func size():
	return cards.size()

func add_card(card:CardData):
	if not is_instance_valid(card):
		return
	cards.append(card)

func discard_card(card:CardData):
	var card_index = cards.find(card)
	if card_index >= 0:
		cards.remove(card_index)
		return true

func discard_all():
	var discarded_cards : Array = cards.duplicate()
	cards.clear()
	return discarded_cards
