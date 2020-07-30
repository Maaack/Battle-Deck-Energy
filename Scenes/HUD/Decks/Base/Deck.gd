tool
extends Control


signal drew_card
signal empty

onready var count_label = $TextureRect/Panel/CountLabel

var deck_settings : DeckSettings = DeckSettings.new() setget set_deck_settings
var deck : Array = []

func set_deck_settings(value:DeckSettings):
	deck_settings = value
	if not is_instance_valid(value):
		return
	deck = value.cards.duplicate()
	_update_deck_count()

func size():
	return deck.size()

func shuffle():
	return deck.shuffle()

func _ready():
	_update_deck_count()

func _update_deck_count():
	if not is_instance_valid(count_label):
		return
	count_label.text = str(deck.size())

func draw_hand(count:int = 1):
	var hand : Array = []
	while(hand.size() < count):
		if deck.size() == 0:
			emit_signal("empty")
			break
		var card : PackedScene = deck.pop_front()
		hand.append(card)
	_update_deck_count()
	emit_signal("drew_cards", hand)

func draw_card():
	if deck.size() == 0:
		emit_signal("empty")
	else:
		var card : PackedScene = deck.pop_front()
		_update_deck_count()
		emit_signal("drew_card", card)

func add_cards(cards:Array):
	for card in cards:
		add_card(card)

func add_card(card:PackedScene):
	deck.append(card)
	_update_deck_count()

	
