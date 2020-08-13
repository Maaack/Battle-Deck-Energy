extends Resource


class_name DeckData

var cards = []

func size():
	return cards.size()

func shuffle():
	cards.shuffle()

func draw_card():
	return cards.pop_front()

func add_card(card:CardData):
	if not is_instance_valid(card):
		cards.append(card)
