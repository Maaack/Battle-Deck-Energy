extends Control


signal ending_turn
signal draw_pile_pressed
signal discard_pile_pressed
signal exhaust_pile_pressed
signal animation_queue_empty
signal drawing_completed
signal discard_completed
signal card_played_on_opportunity(card, opportunity)

enum AnimationType{NONE, DRAWING, SHIFTING, DISCARDING, EXHAUSTING, RESHUFFLING, DRAGGING, PLAYING}

export(float, 0, 512) var opportunity_snap_range = 200.0

onready var animation_queue : Node = $BattleAnimationQueue
onready var card_manager : Node2D = $HandContainer/CardControl/BattleCardManager
onready var opponent_card_manager : Node2D = $HandContainer/CardControl/FocusedCardManager
onready var hand_manager : Node2D = $HandContainer/CardControl/HandManager
onready var player_board : Control = $BattleBoard/MarginContainer/VBoxContainer/PlayerBoard
onready var actions_board : Control = $BattleBoard/MarginContainer/VBoxContainer/ActionsBoard
onready var draw_pile : Control = $BattleBoard/MarginContainer/VBoxContainer/PlayerBoard/DrawPile
onready var discard_pile : Control = $BattleBoard/MarginContainer/VBoxContainer/PlayerBoard/DiscardPile
onready var exhaust_pile : Control = $BattleBoard/MarginContainer/VBoxContainer/PlayerBoard/ExhaustPile
onready var status_update_container : Control = $StatusUpdatesContainer

var effect_calculator = preload("res://Managers/Effects/EffectCalculator.gd")
var effect_text_animation_scene = preload("res://Scenes/PlayerInterface/BattleBoard/ActionsBoard/StatusTextAnimation/StatusTextAnimation.tscn")
var health_status_base = preload("res://Resources/Statuses/Health.tres")
var energy_status_base = preload("res://Resources/Statuses/Energy.tres")
var player_data : CharacterData setget set_player_data
var _drawing_cards_count : int = 0
var _discarding_cards_count : int = 0
var _opportunities_map : Dictionary = {}
var _character_statuses_map : Dictionary = {}
var _card_owner_map : Dictionary = {}
var _nearest_opportunity = null

func set_player_data(value:CharacterData):
	player_data = value
	if is_instance_valid(player_data):
		player_board.set_player_energy(0, player_data.max_energy)
		player_board.set_draw_pile_size(player_data.deck_size())
		actions_board.player_data = player_data
		var interface : CharacterActionsInterface = actions_board.get_actions_instance(player_data)
		interface.connect("update_opportunity", self, "_on_CardContainer_update_opportunity")

func add_opponent(opponent:CharacterData):
	var interface  : CharacterActionsInterface = actions_board.add_opponent(opponent)
	interface.connect("update_opportunity", self, "_on_CardContainer_update_opportunity")
	return interface

func set_draw_pile_count(count:int):
		player_board.set_draw_pile_size(count)

func draw_card(card_data:CardData):
	card_data = card_data
	var draw_pile_offset : Vector2 = draw_pile.get_global_transform().get_origin() - card_manager.get_global_transform().get_origin()
	var hand_offset : Vector2 = hand_manager.get_global_transform().get_origin() - card_manager.get_global_transform().get_origin()
	card_data.transform_data.position = draw_pile_offset
	card_data.transform_data.scale = Vector2(0.1, 0.1)
	var new_transform : TransformData = TransformData.new()
	new_transform.position = hand_offset
	animation_queue.animate_move(card_data, new_transform, 0.4, 0.2, AnimationType.DRAWING)

func draw_cards(cards:Array):
	for card in cards:
		draw_card(card)

func discard_card(card_data:CardData):
	var discard_pile_offset : Vector2 = discard_pile.get_global_transform().get_origin() - card_manager.get_global_transform().get_origin()
	var new_transform : TransformData = TransformData.new()
	new_transform.position = discard_pile_offset
	new_transform.scale = Vector2(0.1, 0.1)
	animation_queue.animate_move(card_data, new_transform, 0.4, 0.2, AnimationType.DISCARDING)

func exhaust_card(card_data:CardData):
	var exhaust_pile_offset : Vector2 = exhaust_pile.get_global_transform().get_origin() - card_manager.get_global_transform().get_origin()
	var new_transform : TransformData = TransformData.new()
	new_transform.position = exhaust_pile_offset
	new_transform.scale = Vector2(0.1, 0.1)
	animation_queue.animate_move(card_data, new_transform, 0.4, 0.2, AnimationType.EXHAUSTING)

func reshuffle_card(card_data:CardData):
	var draw_pile_offset : Vector2 = draw_pile.get_global_transform().get_origin() - card_manager.get_global_transform().get_origin()
	var new_transform : TransformData = TransformData.new()
	new_transform.position = draw_pile_offset
	new_transform.scale = Vector2(0.1, 0.1)
	animation_queue.animate_move(card_data, new_transform, 0.2, 0.1, AnimationType.RESHUFFLING)

func reset_end_turn():
	player_board.reset_end_turn()

func _ready():
	animation_queue.delay_timer()

func _on_HandManager_card_updated(card_data:CardData, transform:TransformData):
	card_manager.move_card(card_data, transform, 0.1)

func _on_CardContainer_update_opportunity(opportunity:OpportunityData, container:CardContainer):
	var card_manager_offset : Vector2 = card_manager.get_global_transform().get_origin()
	opportunity.transform_data.position = container.get_card_parent_position() - card_manager_offset
	if is_instance_valid(opportunity.card_data):
		card_manager.force_move_card(opportunity.card_data, opportunity.transform_data, 0.05)
		opponent_card_manager.force_move_card(opportunity.card_data, opportunity.transform_data, 0.05)

func _calculate_card_mod(card_instance:CardNode2D, source = null, target = null):
	var total_values : Dictionary = {}
	for effect in card_instance.card_data.effects:
		var base_value = effect.amount
		var type_tag = effect.type_tag
		if not type_tag in total_values:
			total_values[type_tag] = 0
		var source_statuses : Array = []
		if source and source in _character_statuses_map and card_instance.card_data.type != CardData.CardType.STRESS:
			source_statuses = _character_statuses_map[source].values()
		var target_statuses : Array = []
		if target and target in _character_statuses_map:
			target_statuses = _character_statuses_map[target].values()
		var total_value = effect_calculator.get_effect_total(base_value, type_tag, source_statuses, target_statuses)
		total_values[type_tag] += total_value
	card_instance.update_card_effects(total_values)
	return total_values

func _new_character_card(character:CharacterData, card:CardData):
	var card_instance : CardNode2D
	if character == player_data:
		card_instance = card_manager.add_card(card)
	else:
		card_instance = opponent_card_manager.add_card(card)
	_card_owner_map[card] = character
	_calculate_card_mod(card_instance, character)
	return card_instance

func _recalculate_all_cards():
	for card in hand_manager.cards:
		var card_instance = card_manager.get_card_instance(card)
		if not is_instance_valid(card_instance):
			continue
		_calculate_card_mod(card_instance, player_data)
	# Opponent cards that are already played
	for opportunity in _opportunities_map:
		if opportunity is OpportunityData:
			if opportunity.card_data == null or opportunity.source == player_data:
				continue
			var card_instance = card_manager.get_card_instance(opportunity.card_data)
			if not is_instance_valid(card_instance):
				continue
			_calculate_card_mod(card_instance, opportunity.source, opportunity.target)

func _drawing_animation(card:CardData, animation:AnimationData):
	player_board.draw_card()
	var card_instance = _new_character_card(player_data, card)
	card_manager.move_card(card, animation.transform_data, animation.tween_time)
	card_instance.connect("tween_completed", self, "_on_draw_card_completed")
	hand_manager.add_card(card)
	_drawing_cards_count += 1

func _discarding_animation(card:CardData, animation:AnimationData):
	var card_instance : CardNode2D = card_manager.get_card_instance(card)
	card_manager.move_card(card, animation.transform_data, animation.tween_time)
	card_manager.lock_card(card)
	card_instance.connect("tween_completed", self, "_on_discard_card_completed")
	_discarding_cards_count += 1

func _exhausting_animation(card:CardData, animation:AnimationData):
	var card_instance : CardNode2D = card_manager.get_card_instance(card)
	card_manager.move_card(card, animation.transform_data, animation.tween_time)
	card_manager.lock_card(card)
	card_instance.connect("tween_completed", self, "_on_exhaust_card_completed")
	_discarding_cards_count += 1

func _on_card_animation_started(animation:CardAnimationData):
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
			card_manager.move_card(card, animation.transform_data, animation.tween_time)

func _on_status_animation_started(animation:StatusAnimationData):
	_update_status(animation.character_data, animation.status_data, animation.delta)

func _on_PlayerBoard_ending_turn():
	emit_signal("ending_turn")
	hand_manager.spread_from_mouse_flag = false

func _on_AnimationQueue_queue_empty():
	emit_signal("animation_queue_empty")

func _on_draw_complete():
	_drawing_cards_count -= 1
	if _discarding_cards_count < 0:
		_discarding_cards_count = 0
		return false
	if _drawing_cards_count == 0 and animation_queue.is_queue_empty():
		emit_signal("drawing_completed")

func _on_discard_complete():
	_discarding_cards_count -= 1
	if _discarding_cards_count < 0:
		_discarding_cards_count = 0
		return false
	if _discarding_cards_count == 0 and animation_queue.is_queue_empty():
		hand_manager.discard_queue()
		emit_signal("discard_completed")
		return true

func _on_discard_card_completed(card_node:CardNode2D):
	hand_manager.queue_card(card_node.card_data)
	card_manager.remove_card(card_node.card_data)
	player_board.discard_card()
	_on_discard_complete()

func _on_exhaust_card_completed(card_node:CardNode2D):
	hand_manager.queue_card(card_node.card_data)
	card_manager.remove_card(card_node.card_data)
	player_board.exhaust_card()
	_on_discard_complete()

func _on_draw_card_completed(card_node:CardNode2D):
	card_node.disconnect("tween_completed", self, "_on_draw_card_completed")
	_on_draw_complete()

func _show_status_update(interface_offset:Vector2, status:StatusData, delta:int):
	var effect_text_instance = effect_text_animation_scene.instance()
	status_update_container.add_child(effect_text_instance)
	effect_text_instance.position = interface_offset
	effect_text_instance.set_status_update(status, delta)

func _show_status_update_over_interface(interface:ActionsInterface, status:StatusData, delta:int):
	var interface_center = Vector2(interface.rect_size.x/2, interface.rect_size.y/2)
	var interface_offset = interface.rect_position + interface_center
	return _show_status_update(interface_offset, status, delta)

func _show_health_update_over_interface(interface:ActionsInterface, delta:int):
	_show_status_update_over_interface(interface, health_status_base, delta)

func _show_energy_update_over_interface(interface:ActionsInterface, delta:int):
	_show_status_update_over_interface(interface, energy_status_base, delta)

func character_gains_health(character:CharacterData, delta:int):
	var actions_interface : ActionsInterface = actions_board.get_actions_instance(character)
	_show_health_update_over_interface(actions_interface, delta)
	actions_interface.update_health()

func character_loses_health(character:CharacterData, delta:int):
	var actions_interface : ActionsInterface = actions_board.get_actions_instance(character)
	_show_health_update_over_interface(actions_interface, -(delta))
	actions_interface.update_health()

func character_gains_energy(character:CharacterData, delta:int):
	var actions_interface : ActionsInterface = actions_board.get_actions_instance(character)
	_show_energy_update_over_interface(actions_interface, delta)
	if character == player_data:
		player_board.gain_energy(delta)
		card_manager.energy_available += delta

func character_loses_energy(character:CharacterData, delta:int):
	var actions_interface : ActionsInterface = actions_board.get_actions_instance(character)
	if character == player_data:
		player_board.lose_energy(delta)
		card_manager.energy_available -= delta

func character_dies(character:CharacterData):
	actions_board.defeat_opponent(character)
	for card in _card_owner_map:
		var card_owner : CharacterData = _card_owner_map[card]
		if card_owner == character:
			opponent_discards_card(card)

func start_turn():
	hand_manager.spread_from_mouse_flag = true
	reset_end_turn()
	
func start_round():
	player_board.advance_round_count()

func clear_opportunities():
	_opportunities_map.clear()

func add_opportunity(opportunity:OpportunityData):
	var container = actions_board.add_opportunity(opportunity)
	if is_instance_valid(container):
		_opportunities_map[opportunity] = container

func remove_opportunity(opportunity:OpportunityData):
	if not opportunity in _opportunities_map:
		return
	actions_board.remove_opportunity(opportunity)
	if _nearest_opportunity == opportunity:
		_nearest_opportunity = null
	_opportunities_map.erase(opportunity)

func remove_all_opportunities():
	actions_board.remove_all_opportunities()
	clear_opportunities()

func _on_PlayerInterface_gui_input(event):
	if event is InputEventMouseMotion:
		if card_manager.dragged_card != null:
			var card_node : CardNode2D = card_manager.dragged_card
			var card_manager_offset : Vector2 = card_manager.get_global_transform().get_origin()
			var final_position : Vector2 =  event.position - card_manager_offset
			card_manager.drag_to_position(final_position)
			var nearest_opportunity = get_nearest_card_opportunity(card_node.card_data, final_position)
			if nearest_opportunity is OpportunityData:
				card_manager.move_card(card_node.card_data, nearest_opportunity.transform_data, 0.1)
			if nearest_opportunity == _nearest_opportunity:
				return
			if _nearest_opportunity != null and nearest_opportunity != _nearest_opportunity:
				var container : OpportunitiesContainer = _opportunities_map[_nearest_opportunity]
				container.glow_on()
			_nearest_opportunity = nearest_opportunity
			var card_owner = _card_owner_map[card_node.card_data]
			var target = null
			if nearest_opportunity is OpportunityData:
				var container : OpportunitiesContainer = _opportunities_map[nearest_opportunity]
				container.glow_special()
				target = nearest_opportunity.target
			_calculate_card_mod(card_node, card_owner, target)

func get_player_card_opportunities(card:CardData):
	var filtered_opportunities : Dictionary = {}
	for opportunity in _opportunities_map:
		if opportunity is OpportunityData:
			if card.type == opportunity.type and player_data == opportunity.source:
				filtered_opportunities[opportunity] = _opportunities_map[opportunity]
	return filtered_opportunities

func _openings_glow_on(card:CardData):
	for container in get_player_card_opportunities(card).values():
		if container is OpportunitiesContainer:
			container.glow_on()

func _openings_glow_off(card:CardData):
	for container in get_player_card_opportunities(card).values():
		if container is OpportunitiesContainer:
			container.glow_off()

func get_nearest_card_opportunity(card:CardData, position = null):
	if position == null:
		position = card.transform_data.position
	var shortest_distance : float = opportunity_snap_range
	var nearest_opportunity = null
	for opportunity in get_player_card_opportunities(card):
		if opportunity is OpportunityData:
			var opportunity_transform : TransformData = opportunity.transform_data
			if opportunity_transform.position.distance_to(position) < shortest_distance:
				shortest_distance = opportunity_transform.position.distance_to(position)
				nearest_opportunity = opportunity
	return nearest_opportunity

func _on_dragging_card(card:CardData):
	hand_manager.spread_from_mouse_flag = false
	_openings_glow_on(card)

func _on_dropping_card(card:CardData):
	var nearest_opportunity = get_nearest_card_opportunity(card)
	_openings_glow_off(card)
	if nearest_opportunity is OpportunityData:
		emit_signal("card_played_on_opportunity", card, nearest_opportunity)
	hand_manager.spread_from_mouse_flag = true
	hand_manager.update_hand()

func _on_BattleCardManager_dragging_card(card_data:CardData):
	_on_dragging_card(card_data)

func _on_BattleCardManager_dropping_card(card_data:CardData):
	_on_dropping_card(card_data)

func play_card(character:CharacterData, card:CardData, opportunity:OpportunityData):
	if not opportunity in _opportunities_map:
		print("Warning: %s doesn't exist in opportunities map %s ." % [opportunity, str(_opportunities_map)])
		return
	opportunity.card_data = card
	var opening_transform : TransformData = opportunity.transform_data.duplicate()
	if character == player_data:
		hand_manager.discard_card(card)
		card_manager.move_card(card, opening_transform)
		var card_instance : CardNode2D = card_manager.get_card_instance(card)
		card_instance.play_card()
	else:
		card.transform_data = opening_transform
		var card_instance : CardNode2D = _new_character_card(character, card)
		_calculate_card_mod(card_instance, character, opportunity.target)

func opponent_discards_card(card:CardData):
	opponent_card_manager.remove_card(card)

func _update_status(character:CharacterData, status:StatusData, delta:int):
	if not character in _character_statuses_map:
		_character_statuses_map[character] = {}
	_character_statuses_map[character][status.type_tag] = status
	var interface = actions_board.add_status(character, status)
	if not interface is ActionsInterface:
		return
	_show_status_update_over_interface(interface, status, delta)
	_recalculate_all_cards()
	if status.get_stack_value() == 0:
		actions_board.remove_status(character, status)
		_character_statuses_map[character].erase(status.type_tag)

func update_status(character:CharacterData, status:StatusData, delta:int):
	animation_queue.animate_status(character, status, delta)

func _on_PlayerBoard_draw_pile_pressed():
	emit_signal("draw_pile_pressed")

func _on_PlayerBoard_discard_pile_pressed():
	emit_signal("discard_pile_pressed")

func _on_PlayerBoard_exhaust_pile_pressed():
	emit_signal("exhaust_pile_pressed")

func _on_PlayerInterface_resized():
	if is_instance_valid($ResizeTimer):
		$ResizeTimer.start()

func _on_ResizeTimer_timeout():
	for opportunity in _opportunities_map:
		_on_CardContainer_update_opportunity(opportunity, _opportunities_map[opportunity])

func _on_BattleAnimationQueue_animation_started(animation_data:AnimationData):
	if animation_data is CardAnimationData:
		_on_card_animation_started(animation_data)
	elif animation_data is StatusAnimationData:
		_on_status_animation_started(animation_data)

func _on_BattleAnimationQueue_queue_empty():
	emit_signal("animation_queue_empty")
