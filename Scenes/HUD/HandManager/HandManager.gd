extends Node2D


signal discarding_card

onready var cards_container = $CardsContainer

export(float, 0, 4096) var starting_width : float = 512
export(float, 0, 4096) var ending_width : float = 1024
export(int, 0, 32) var max_hand_size : int = 8

var cards : Array 


func add_card(card:Card):
	cards.append(card)
	card.connect("discard", self, "_on_Card_discard")
	_fan_cards()

func _on_Card_discard(discarding_card:Card):
	var index : int = cards.find(discarding_card)
	cards.remove(index)
	_fan_cards()
	emit_signal("discarding_card", discarding_card)

func discard_hand():
	var cards_to_discard : Array = cards.duplicate()
	for card in cards_to_discard:
		if card is Card:
			card.discard()

func _fan_cards():
	var card_max_ratio : float = float(cards.size()) / float(max_hand_size)
	var width_diff : float = (ending_width - starting_width) * card_max_ratio
	var current_width : float = starting_width + width_diff
	var divided_space : float = current_width / (cards.size() + 1)
	var horizontal_center = -(current_width / 2)
	var iter : int = 0
	for card in cards:
		iter += 1
		if card is Card:
			var x_position : float = horizontal_center + (iter * divided_space)
			var x_offset : Vector2 = Vector2(x_position, 0) + global_position
			card.tween_to_position(x_offset)
	
