extends Node2D


signal discarding_card(card)
signal selecting_card(card)
signal releasing_card(card)

export(float, 0, 4096) var starting_width : float = 512
export(float, 0, 4096) var ending_width : float = 1024
export(int, 0, 32) var max_hand_size : int = 8
export(float, 0, 1024) var ignore_mouse_range : float = 200
export(float, 0, 1024) var fan_cards_from_center : float = 60
export(float, 0.0, 2.0) var fan_speed : float = 0.2

var cards : Array

func add_card(card:Card):
	cards.append(card)
	fan_cards()

func discard_hand():
	cards.clear()

func discard_card(card:Card):
	var index : int = cards.find(card)
	if index > -1:
		cards.remove(index)

func get_card_positions():
	var positions : Array = []
	var card_max_ratio : float = float(cards.size()) / float(max_hand_size)
	var width_diff : float = (ending_width - starting_width) * card_max_ratio
	var current_width : float = starting_width + width_diff
	var divided_space : float = current_width / (cards.size() + 1)
	var horizontal_center = -(current_width / 2)
	var iter : int = 0
	for card in cards:
		iter += 1
		if card is Card:
			var card_position_x : float = horizontal_center + (iter * divided_space)
			var card_position : Vector2 = Vector2(card_position_x, 0)
			positions.append(card_position)
	return positions

func get_nearest_card(input_position:Vector2):
	var nearest_card : Card
	var shortest_distance : float = ignore_mouse_range
	for card in cards:
		if card is Card:
			var diff : Vector2 = card.position - input_position
			var distance : float = diff.length()
			if distance < shortest_distance:
				shortest_distance = distance
				nearest_card = card
	return nearest_card

func fan_cards():
	var positions : Array = get_card_positions()
	for card in cards:
		if card is Card:
			card.tween_to_position(positions.pop_front())

func fan_cards_away_from_card(focused_card:Card):
	var positions : Array = get_card_positions()
	var card_index : int = cards.find(focused_card)
	positions = _fan_positions_from_index(positions, card_index)
	for card in cards:
		if card is Card:
			card.tween_to_position(positions.pop_front(), fan_speed)

func _fan_positions_from_index(positions:Array, card_index:int):
	var new_positions : Array
	var index : int = 0
	for card_position in positions:
		if index != card_index:
			var hand_distance = abs(index - card_index)
			var fan_distance = fan_cards_from_center / hand_distance
			card_position += Vector2(fan_distance * sign(index - card_index), 0)
		new_positions.append(card_position)
		index += 1
	return new_positions
