extends Control


onready var draw_pile = $DrawPile
onready var discard_pile = $DiscardPile
onready var hand = $CenterBottom/Hand

var starter_deck = preload("res://Resources/DeckSettings/StartingDeck.tres")

func _ready():
	randomize()
	draw_pile.set_deck_settings(starter_deck)
	draw_pile.shuffle()
	var cards : Array = draw_pile.draw_hand(5)
	for card_scene in cards:
		hand.add_card(card_scene)

func _on_EndTurnButton_pressed():
	var discarded_cards : Array = hand.discard_hand()
	discard_pile.add_cards(discarded_cards)
