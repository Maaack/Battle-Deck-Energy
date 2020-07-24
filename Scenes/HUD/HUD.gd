extends Control


onready var draw_pile = $BottomLeft/DrawPile
onready var hand = $CenterBottom/Hand

var starter_deck = preload("res://Resources/DeckSettings/StartingDeck.tres")

func _ready():
	randomize()
	draw_pile.set_deck_settings(starter_deck)
	draw_pile.shuffle()
	var cards : Array = draw_pile.draw_hand(5)
	for card_scene in cards:
		hand.add_card(card_scene)
