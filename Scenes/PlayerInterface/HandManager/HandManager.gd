extends Node2D


signal hand_updated
signal card_updated(card)

const NO_INDEX = -1

export(float, 0, 4096) var starting_width : float = 512
export(float, 0, 4096) var ending_width : float = 1024
export(float, 0, 4096) var hand_center_distance : float = 1024
export(int, 0, 32) var max_hand_size : int = 8
export(float, 0, 1024) var ignore_mouse_range : float = 200
export(float, 0, 1024) var fan_cards_from_center : float = 60
export(float, 0.0, 2.0) var fan_speed : float = 0.2
export(Vector2) var offset_nearest_card : Vector2 = Vector2(0.0, -80)
export(Vector2) var scale_nearest_card : Vector2 = Vector2(1.25, 1.25)

var cards : Dictionary = {}
var spread_from_mouse_flag : bool = false
var spread_from_index : int = NO_INDEX
var queue: Array = []

func add_card(card_key):
	cards[card_key] = PRSData.new()
	update_hand()

func discard_card(card_key):
	if card_key in cards:
		cards.erase(card_key)
		update_hand()

func queue_card(card_key):
	queue.append(card_key)

func discard_queue():
	for card_key in queue:
		discard_card(card_key)
	queue.empty()

func get_prs_array():
	var prs_array : Array = []
	var card_max_ratio : float = float(cards.size()) / float(max_hand_size)
	var width_diff : float = (ending_width - starting_width) * card_max_ratio
	var current_width : float = starting_width + width_diff
	var divided_space : float = current_width / (cards.size() + 1)
	var left_side = -(current_width / 2)
	var iter : int = 0
	for card in cards:
		iter += 1
		var new_prs : PRSData = PRSData.new()
		var card_position_x : float = left_side + (iter * divided_space)
		var card_position_y : float = hand_center_distance - hand_center_distance * sqrt(1 - pow(card_position_x/hand_center_distance, 2))
		new_prs.position = Vector2(card_position_x, card_position_y)
		new_prs.rotation = sin(card_position_x/hand_center_distance)
		prs_array.append(new_prs)
	return prs_array

func spread_positions_from_index(prs_array:Array, card_index:int):
	var index : int = 0
	for prs in prs_array:
		if prs is PRSData:
			if index != card_index:
				var hand_distance = abs(index - card_index)
				var fan_distance = fan_cards_from_center / hand_distance
				prs.position += Vector2(fan_distance * sign(index - card_index), 0)
			else:
				prs.position += offset_nearest_card
				prs.scale = scale_nearest_card
				prs.rotation = 0.0
		index += 1
	return prs_array

func get_prs_array_spread():
	var prs_array : Array = get_prs_array()
	if spread_from_mouse_flag and spread_from_index >= 0:
		prs_array = spread_positions_from_index(prs_array, spread_from_index)
	return prs_array

func update_hand():
	var prs_array = get_prs_array_spread()
	var prs_index = 0
	for card_key in cards:
		var new_prs_data : PRSData = prs_array[prs_index]
		cards[card_key] = prs_array[prs_index]
		emit_signal("card_updated", card_key, cards[card_key])
		prs_index += 1
	emit_signal("hand_updated")

func get_nearest_index(input_position:Vector2):
	var nearest_index : int = -1
	var shortest_distance : float = ignore_mouse_range
	var index : int = 0
	for card_key in cards:
		var prs : PRSData = cards[card_key]
		var diff : Vector2 = prs.position - input_position
		var distance : float = diff.length()
		if distance < shortest_distance:
			shortest_distance = distance
			nearest_index = index
		index += 1
	return nearest_index

func _input(event):
	if event is InputEventMouseMotion:
		var relative_position : Vector2 = event.get_position() - get_global_transform().get_origin()
		var nearest_index : int = get_nearest_index(relative_position)
		var diff_flag : bool
		if nearest_index >= 0:
			diff_flag = spread_from_index != nearest_index
			spread_from_index = nearest_index
		else:
			diff_flag = spread_from_index != NO_INDEX
			spread_from_index = NO_INDEX
		if spread_from_mouse_flag and diff_flag:
			update_hand()
