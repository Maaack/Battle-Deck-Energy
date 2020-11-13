extends Resource


class_name DeckData

export(String) var title : String = ""
export(Texture) var icon : Texture
export(Array, Resource) var cards : Array = []

func size():
	return cards.size()

func shuffle():
	cards.shuffle()

func draw_card():
	return cards.pop_front()

func add_card(card:CardData):
	if not is_instance_valid(card):
		return
	cards.append(card)

func clear():
	cards.clear()

func draw_all():
	var discarded : Array = cards.duplicate()
	clear()
	return discarded

func draw_specific_card(card:CardData):
	var card_index : int = cards.find(card)
	if card_index < 0:
		return
	cards.remove(card_index)
	return card
