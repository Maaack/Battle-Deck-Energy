extends Node2D


signal discarding_card

onready var cards_container = $CardsContainer

export(float, 0, 4096) var starting_width : float = 512
export(float, 0, 4096) var ending_width : float = 1024
export(int, 0, 32) var max_hand_size : int = 8
export(float, 0, 1024) var ignore_mouse_range : float = 200
export(float, 0, 1024) var fan_cards_from_center : float = 60
export(float, 0.0, 2.0) var fan_speed : float = 0.2

var cards : Array
var hovering = null
var discarding_cards = []
var energy_available : int = 0

func add_card(card:Card):
	cards.append(card)
	card.connect("mouse_entered", self, "_on_Card_mouse_entered", [card])
	card.connect("mouse_exited", self, "_on_Card_mouse_exited", [card])
	card.connect("mouse_clicked", self, "_on_Card_mouse_clicked", [card])
	_fan_cards()

func _on_Card_discard(discarding_card:Card):
	var index : int = cards.find(discarding_card)
	cards.remove(index)
	_fan_cards()
	emit_signal("discarding_card", discarding_card)

func discard_hand():
	while(cards.size() > 0):
		var card : Card = cards.pop_front()
		discard_card(card)

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

func _input(event):
	if event is InputEventMouseMotion:
		var relative_position : Vector2 = event.get_position() - get_global_transform().get_origin()
		var nearest_card : Card = get_nearest_card(relative_position)
		if is_instance_valid(nearest_card):
			_fan_cards_away_from_card(nearest_card)
		else:
			_fan_cards()

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

func _fan_cards():
	var positions : Array = get_card_positions()
	for card in cards:
		if card is Card:
			card.tween_to_position(positions.pop_front())

func _fan_cards_away_from_card(focused_card:Card):
	var positions : Array = get_card_positions()
	var card_index : int = cards.find(focused_card)
	positions = _fan_positions_from_index(positions, card_index)
	for card in cards:
		if card is Card:
			card.tween_to_position(positions.pop_front(), 0.2)

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

func _on_Card_mouse_entered(card:Card):
	hovering = card
	if card.get_energy_cost() <= energy_available:
		card.glow_on()
	else:
		card.glow_not()

func _on_Card_mouse_exited(card:Card):
	hovering = null
	card.glow_off()

func _on_Card_mouse_clicked(card:Card):
	if card.get_energy_cost() <= energy_available:
		var index : int = cards.find(card)
		discard_card(card)
		cards.remove(index)
		_fan_cards()

func discard_card(card:Card):
	discarding_cards.append(card)
	emit_signal("discarding_card", card)

func discarding_card_complete(card:Card):
	var index : int = discarding_cards.find(card)
	discarding_cards.remove(index)

func is_discarding_card(card:Card):
	return card in discarding_cards
