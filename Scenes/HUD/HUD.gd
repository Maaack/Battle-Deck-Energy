extends Control


onready var draw_pile = $DrawPile
onready var discard_pile = $DiscardPile
onready var hand = $Hand
onready var draw_hand_timer = $DrawHandTimer
onready var draw_card_timer = $DrawCardTimer
onready var reshuffle_card_timer = $ReshuffleCardTimer
onready var health_meter = $HealthMeter
onready var end_turn_button = $EndTurnButton/Button

var starter_deck : Resource = preload("res://Resources/DeckSettings/StartingDeck.tres")
var _drawing_cards : int = 0
var _reshuffling_cards : int = 0

func _ready():
	randomize()
	draw_pile.set_deck_settings(starter_deck)
	draw_pile.shuffle()
	draw_hand_timer.start()

func draw_cards(count:int = 1):
	_drawing_cards = count
	if _drawing_cards > 0:
		draw_pile.draw_card()

func _drawing_cards_completed():
	end_turn_button.disabled = false

func reshuffle_discard_pile():
	_reshuffling_cards = discard_pile.size()
	if _reshuffling_cards > 0:
		discard_pile.draw_card()

func _reshuffling_cards_completed():
	_shuffle_and_draw()

func _on_EndTurnButton_pressed():
	var discarded_cards : Array = hand.discard_hand()
	discard_pile.add_cards(discarded_cards)
	if draw_pile.size() > 0:
		draw_hand_timer.start()
	else:
		draw_cards(5)

func _on_DrawHandTimer_timeout():
	draw_cards(5)

func _on_DrawPile_drew_card(card:PackedScene):
	hand.add_card(card)
	_drawing_cards -= 1
	if _drawing_cards > 0:
		draw_card_timer.start()
	else:
		_drawing_cards_completed()
	
func _on_DrawPile_empty():
	if discard_pile.size() > 0:
		reshuffle_discard_pile()
	else:
		_drawing_cards_completed()

func _on_DiscardPile_drew_card(card:PackedScene):
	draw_pile.add_card(card)
	_reshuffling_cards -= 1
	if _reshuffling_cards > 0:
		reshuffle_card_timer.start()
	else:
		_reshuffling_cards_completed()

func _on_DiscardPile_empty():
	_reshuffling_cards_completed()
	_drawing_cards_completed()

func _shuffle_and_draw():
	draw_pile.shuffle()
	if _drawing_cards > 0:
		draw_card_timer.start()

func _on_DrawCardTimer_timeout():
	draw_pile.draw_card()

func _on_ReshuffleCardTimer_timeout():
	discard_pile.draw_card()
