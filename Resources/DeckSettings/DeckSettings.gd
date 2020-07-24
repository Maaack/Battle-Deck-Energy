extends Resource


class_name DeckSettings

export(Array, PackedScene) var cards : Array = []


func _to_string():
	return str(cards)

func size():
	return cards.size()

func shuffle():
	return cards.shuffle()

func draw_hand(count : int = 1):
	var hand : Array = []
	for _i in range(count):
		if cards.size() == 0:
			break
		hand.append(cards.pop_front())
	return hand

func draw_card():
	var hand : Array = draw_hand(1)
	if hand.size() < 1:
		return
	return hand.pop_back()
