extends EffectData


class_name DeckModEffectData

enum DestinationMode{HAND, DRAW, DISCARD}

@export var starting_card: Resource: set = set_starting_card
@export var destination: DestinationMode = DestinationMode.HAND

var card : CardData

func _reset_card():
	card = starting_card.duplicate()

func reset():
	_reset_card()

func set_starting_card(value:CardData):
	starting_card = value
	_reset_card()
