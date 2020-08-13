extends Resource


class_name HandData

var cards = []

func size():
	return cards.size()

func pull_card(index:int):
	var pulled_card : CardData = cards[index]
	cards.remove(index)
	return pulled_card

func add_card(card:CardData):
	if not is_instance_valid(card):
		cards.append(card)

func discard():
	var discarded_cards : Array = cards.duplicate()
	cards.clear()
	return discarded_cards
