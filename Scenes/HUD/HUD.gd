extends Control


var starter_deck = preload("res://Resources/DeckSettings/StartingDeck.tres")

func _ready():
	randomize()
	$DrawPile.set_deck_settings(starter_deck)
	$DrawPile.shuffle()
	var cards : Array = $DrawPile.draw_hand(5)
	for card_scene in cards:
		$CenterBottom/Hand.add_card(card_scene)
