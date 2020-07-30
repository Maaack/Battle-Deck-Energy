extends Resource


class_name DeckSettings

export(Array, PackedScene) var cards : Array = []


func _to_string():
	return str(cards)

func size():
	return cards.size()
