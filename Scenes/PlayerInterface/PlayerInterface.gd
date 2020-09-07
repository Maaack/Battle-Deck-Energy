extends Control


signal ending_turn
signal animation_queue_empty
signal drawing_completed
signal discard_completed
signal card_played_on_opportunity(card, opportunity)

enum AnimationType{NONE, DRAWING, SHIFTING, DISCARDING, EXHAUSTING, RESHUFFLING, DRAGGING, PLAYING}

onready var animation_queue : Node = $AnimationQueue
onready var card_manager : Node2D = $HandContainer/CardControl/CardManager
onready var hand_manager : Node2D = $HandContainer/CardControl/HandManager
onready var player_board : Control = $BattleBoard/MarginContainer/VBoxContainer/PlayerBoard
onready var actions_board : Control = $BattleBoard/MarginContainer/VBoxContainer/ActionsBoard
onready var draw_pile : Control = $BattleBoard/MarginContainer/VBoxContainer/PlayerBoard/DrawPile
onready var discard_pile : Control = $BattleBoard/MarginContainer/VBoxContainer/PlayerBoard/DiscardPile
onready var exhaust_pile : Control = $BattleBoard/MarginContainer/VBoxContainer/PlayerBoard/ExhaustPile

var effect_calculator = preload("res://Managers/Effects/EffectCalculator.gd")
var player_data : CharacterData setget set_player_data
var _drawing_cards_count : int = 0
var _discarding_cards_count : int = 0
var _opportunities_map : Dictionary = {}
var _character_statuses_map : Dictionary = {}
var _card_owner_map : Dictionary = {}
var _nearest_battle_opening = null

func set_player_data(value:CharacterData):
	player_data = value
	if is_instance_valid(player_data):
		player_board.set_player_energy(0, player_data.max_energy)
		player_board.set_player_health(player_data.health, player_data.max_health)
		player_board.set_draw_pile_size(player_data.deck_size())
		actions_board.player_data = player_data

func add_opponent(opponent:CharacterData):
	return actions_board.add_opponent(opponent)

func set_draw_pile_count(count:int):
		player_board.set_draw_pile_size(count)

func draw_card(card_data:CardData):
	card_data = card_data
	var draw_pile_offset : Vector2 = draw_pile.get_global_transform().get_origin() - card_manager.get_global_transform().get_origin()
	var hand_offset : Vector2 = hand_manager.get_global_transform().get_origin() - card_manager.get_global_transform().get_origin()
	card_data.prs.position = draw_pile_offset
	card_data.prs.scale = Vector2(0.1, 0.1)
	var new_prs : PRSData = PRSData.new()
	new_prs.position = hand_offset
	animation_queue.animate_move(card_data, new_prs, 0.4, 0.2, AnimationType.DRAWING)

func draw_cards(cards:Array):
	for card in cards:
		draw_card(card)

func discard_card(card_data:CardData):
	var discard_pile_offset : Vector2 = discard_pile.get_global_transform().get_origin() - card_manager.get_global_transform().get_origin()
	var new_prs : PRSData = PRSData.new()
	new_prs.position = discard_pile_offset
	new_prs.scale = Vector2(0.1, 0.1)
	animation_queue.animate_move(card_data, new_prs, 0.4, 0.2, AnimationType.DISCARDING)

func exhaust_card(card_data:CardData):
	var exhaust_pile_offset : Vector2 = exhaust_pile.get_global_transform().get_origin() - card_manager.get_global_transform().get_origin()
	var new_prs : PRSData = PRSData.new()
	new_prs.position = exhaust_pile_offset
	new_prs.scale = Vector2(0.1, 0.1)
	animation_queue.animate_move(card_data, new_prs, 0.4, 0.2, AnimationType.EXHAUSTING)

func reshuffle_card(card_data:CardData):
	var draw_pile_offset : Vector2 = draw_pile.get_global_transform().get_origin() - card_manager.get_global_transform().get_origin()
	var new_prs : PRSData = PRSData.new()
	new_prs.position = draw_pile_offset
	new_prs.scale = Vector2(0.1, 0.1)
	animation_queue.animate_move(card_data, new_prs, 0.2, 0.1, AnimationType.RESHUFFLING)

func reset_end_turn():
	player_board.reset_end_turn()

func _ready():
	animation_queue.delay_timer()

func _on_HandManager_card_updated(card_data:CardData, prs:PRSData):
	card_manager.move_card(card_data, prs, 0.1, AnimationType.SHIFTING)

func _on_CardSlot_moved(opening:BattleOpening):
	var card_manager_offset : Vector2 = get_global_transform().get_origin() - card_manager.get_global_transform().get_origin()
	opening.prs_data.position = opening.card_slot_node.get_global_transform().get_origin() + card_manager_offset
	if is_instance_valid(opening.assigned_card):
		card_manager.force_move_card(opening.assigned_card, opening.prs_data, 0.05)

func _calculate_card_mod(card_instance:BattleCard, source:CharacterData, target = null):
	var total_values : Dictionary = {}
	for effect_type in card_instance.base_values:
		var base_value = card_instance.base_values[effect_type]
		var source_statuses : Array
		if source and source in _character_statuses_map:
			source_statuses = _character_statuses_map[source]
		var target_statuses : Array
		if target and target in _character_statuses_map:
			target_statuses = _character_statuses_map[target]
		var total_value = effect_calculator.get_effect_total(base_value, effect_type, source_statuses, target_statuses)
		total_values[effect_type] = total_value
	card_instance.update_card_effects(total_values)
	return total_values

func _new_character_card(character:CharacterData, card:CardData):
	var card_instance : BattleCard = card_manager.add_card(card)
	_card_owner_map[card] = character
	_calculate_card_mod(card_instance, character)
	return card_instance

func _recalculate_all_cards():
	for card in _card_owner_map:
		var owner : CharacterData = _card_owner_map[card]
		var card_instance = card_manager.get_card_instance(card)
		if not is_instance_valid(card_instance):
			continue
		_calculate_card_mod(card_instance, owner)

func _drawing_animation(card:CardData, animation:AnimationData):
	player_board.draw_card()
	var card_instance = _new_character_card(player_data, card)
	card_instance.connect("tween_completed", self, "_on_draw_card_completed")
	card_manager.move_card(card, animation.prs, animation.tween_time, AnimationType.DRAWING)
	hand_manager.add_card(card)
	_drawing_cards_count += 1

func _discarding_animation(card:CardData, animation:AnimationData):
	var card_instance : BattleCard = card_manager.get_card_instance(card)
	card_instance.connect("tween_completed", self, "_on_discard_card_completed")
	card_manager.move_card(card, animation.prs, animation.tween_time)
	_discarding_cards_count += 1

func _exhausting_animation(card:CardData, animation:AnimationData):
	var card_instance : BattleCard = card_manager.get_card_instance(card)
	card_instance.connect("tween_completed", self, "_on_exhaust_card_completed")
	card_manager.move_card(card, animation.prs, animation.tween_time)
	_discarding_cards_count += 1

func _on_AnimationQueue_animation_started(animation:AnimationData):
	var card : CardData = animation.card_data
	match(animation.animation_type):
		AnimationType.DRAWING:
			_drawing_animation(card, animation)
		AnimationType.DISCARDING:
			_discarding_animation(card, animation)
		AnimationType.EXHAUSTING:
			_exhausting_animation(card, animation)
		AnimationType.RESHUFFLING:
			player_board.reshuffle_card()
		_:
			card_manager.move_card(card, animation.prs, animation.tween_time)

func _on_PlayerBoard_ending_turn():
	emit_signal("ending_turn")
	hand_manager.spread_from_mouse_flag = false

func _on_AnimationQueue_queue_empty():
	emit_signal("animation_queue_empty")

func _discard_complete():
	_discarding_cards_count -= 1
	if _discarding_cards_count < 0:
		_discarding_cards_count = 0
		return false
	if _discarding_cards_count == 0:
		hand_manager.discard_queue()
		emit_signal("discard_completed")
		return true

func _on_discard_card_completed(card_data:CardData):
	hand_manager.queue_card(card_data)
	card_manager.remove_card(card_data)
	player_board.discard_card()
	if _discard_complete():
		hand_manager.discard_queue()

func _on_exhaust_card_completed(card_data:CardData):
	hand_manager.queue_card(card_data)
	card_manager.remove_card(card_data)
	player_board.exhaust_card()
	if _discard_complete():
		hand_manager.discard_queue()

func _on_draw_card_completed(card_data:CardData):
	var card_instance : BattleCard = card_manager.get_card_instance(card_data)
	card_instance.disconnect("tween_completed", self, "_on_draw_card_completed")
	_drawing_cards_count -= 1
	if _drawing_cards_count == 0:
		if _drawing_cards_count < 0:
			_drawing_cards_count = 0
			return
		emit_signal("drawing_completed")

func _update_opponent_meters(character:CharacterData):
	var opponent_actions = actions_board.get_actions_instance(character)
	if opponent_actions is OpponentActionsInterface:
		opponent_actions.update()

func character_gains_health(character:CharacterData, amount:int):
	if character == player_data:
		player_board.gain_health(amount)
	else:
		_update_opponent_meters(character)

func character_loses_health(character:CharacterData, amount:int):
	if character == player_data:
		player_board.lose_health(amount)
	else:
		_update_opponent_meters(character)

func character_gains_energy(character:CharacterData, amount:int):
	if character == player_data:
		player_board.gain_energy(amount)
		card_manager.energy_limit += amount
	else:
		_update_opponent_meters(character)

func character_loses_energy(character:CharacterData, amount:int):
	if character == player_data:
		player_board.lose_energy(amount)
		card_manager.energy_limit -= amount
	else:
		_update_opponent_meters(character)

func character_dies(character:CharacterData):
	actions_board.defeat_opponent(character)

func start_turn():
	hand_manager.spread_from_mouse_flag = true
	reset_end_turn()
	
func start_round():
	player_board.advance_round_count()

func _map_opportunity_node(opening:BattleOpening):
	if not is_instance_valid(opening):
		return
	opening.connect("card_slot_moved", self, "_on_CardSlot_moved", [opening])
	_opportunities_map[opening.opportunity_data] = opening

func _map_opportunity_nodes(openings:Array):
	for opening in openings:
		if opening is BattleOpening:
			_map_opportunity_node(opening)

func clear_opportunities():
	_opportunities_map.clear()

func add_opening(opportunity:OpportunityData):
	var opening : BattleOpening = actions_board.add_opening(opportunity)
	_map_opportunity_node(opening)
	return opening

func add_openings(opportunities:Array):
	var openings : Array = actions_board.add_openings(opportunities)
	_map_opportunity_nodes(openings)
	return openings

func remove_all_openings():
	actions_board.remove_all_openings()
	clear_opportunities()

func _on_PlayerInterface_gui_input(event):
	if event is InputEventMouseMotion:
		if card_manager.dragged_card != null:
			var card : CardData = card_manager.dragged_card
			var card_manager_offset : Vector2 = get_global_transform().get_origin() - card_manager.get_global_transform().get_origin()
			var prs_data = PRSData.new()
			prs_data.position = event.position + card_manager_offset
			prs_data.scale = Vector2(1.25, 1.25)
			card_manager.move_card(card, prs_data, 0.1, AnimationType.DRAGGING)
			var nearest_battle_opening = get_nearest_battle_opening(card)
			if nearest_battle_opening == _nearest_battle_opening:
				return
			if _nearest_battle_opening != null and nearest_battle_opening != _nearest_battle_opening:
				_nearest_battle_opening.glow_on()
			_nearest_battle_opening = nearest_battle_opening
			var card_instance = card_manager.get_card_instance(card)
			var card_owner = _card_owner_map[card]
			var target = null
			if nearest_battle_opening is BattleOpening:
				nearest_battle_opening.glow_special()
				target = nearest_battle_opening.get_target()
			_calculate_card_mod(card_instance, card_owner, target)

func get_player_card_openings(card:CardData):
	var filtered_openings : Array = []
	var openings : Array = actions_board.get_player_battle_openings()
	for opening in openings:
		if opening is BattleOpening:
			if card.type_tag in opening.opportunity_data.allowed_types:
				filtered_openings.append(opening)
	return filtered_openings

func _openings_glow_on(card:CardData):
	for battle_opening in get_player_card_openings(card):
		battle_opening.glow_on()

func _openings_glow_off(card:CardData):
	for battle_opening in get_player_card_openings(card):
		battle_opening.glow_off()

func get_nearest_battle_opening(card:CardData):
	var card_prs : Vector2 = card.prs.position
	var shortest_distance : float = 120.0 # Ignore drop range
	var nearest_battle_opening = null
	for battle_opening in get_player_card_openings(card):
		if battle_opening is BattleOpening:
			var opening_prs : PRSData = battle_opening.prs_data
			if opening_prs.position.distance_to(card_prs) < shortest_distance:
				shortest_distance = opening_prs.position.distance_to(card_prs)
				nearest_battle_opening = battle_opening
	return nearest_battle_opening

func _on_CardManager_dragging_card(card:CardData):
	hand_manager.spread_from_mouse_flag = false
	_openings_glow_on(card)

func _on_CardManager_dropping_card(card:CardData):
	var nearest_battle_opening = get_nearest_battle_opening(card)
	_openings_glow_off(card)
	if nearest_battle_opening is BattleOpening:
		emit_signal("card_played_on_opportunity", card, nearest_battle_opening.opportunity_data)
	hand_manager.spread_from_mouse_flag = true
	hand_manager.update_hand()

func play_card(character:CharacterData, card:CardData, opportunity:OpportunityData):
	if not opportunity in _opportunities_map:
		print("Warning: %s doesn't exist in opportunities map %s ." % [opportunity, str(_opportunities_map)])
		return
	var battle_opening : BattleOpening = _opportunities_map[opportunity]
	battle_opening.assigned_card = card
	var opening_prs : PRSData = battle_opening.prs_data.duplicate()
	if character == player_data:
		hand_manager.discard_card(card)
	else:
		card.prs = opening_prs
		_new_character_card(character, card)
	card_manager.move_card(card, opening_prs, 0.2, AnimationType.PLAYING)

func opponent_discards_card(card:CardData):
	card_manager.remove_card(card)

func add_status(character:CharacterData, status:StatusData):
	if not character in _character_statuses_map:
		_character_statuses_map[character] = []
	if not status in _character_statuses_map[character]:
		_character_statuses_map[character].append(status)
	actions_board.add_status(character, status)
	_recalculate_all_cards()

func remove_status(character:CharacterData, status:StatusData):
	if not character in _character_statuses_map:
		return
	if not status in _character_statuses_map[character]:
		return
	actions_board.remove_status(character, status)
	_character_statuses_map[character].erase(status)
	_recalculate_all_cards()

