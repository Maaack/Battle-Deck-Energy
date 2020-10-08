extends Control


signal player_won
signal player_lost
signal view_deck_pressed(deck)
signal card_inspected(card_node)
signal card_forgotten(card_node)
signal status_inspected(status_icon)
signal status_forgotten(status_icon)

onready var advance_phase_timer = $AdvancePhaseTimer
onready var advance_character_timer = $AdvanceCharacterTimer
onready var advance_action_timer = $AdvanceActionTimer
onready var battle_end_timer = $BattleEndDelayTimer
onready var player_interface = $PlayerInterface
onready var player_battle_manager = $CharacterBattleManager
onready var ai_opponents_manager = $AIOpponentsManager
onready var battle_phase_manager = $BattlePhaseManager
onready var battle_opportunities_manager = $BattleOpportunitiesManager
onready var effects_manager = $EffectManager

var player_data : CharacterData setget set_player_data
var opponents : Array = [] setget set_opponents

var _character_manager_map : Dictionary = {}
var _round_opportunities_map : Dictionary = {}
var _skip_opening_phase : bool = false
var _battle_ended : bool = false

func set_player_data(value:CharacterData):
	player_data = value
	if is_instance_valid(player_data):
		player_interface.player_data = player_data
		player_battle_manager.character_data = player_data
		battle_opportunities_manager.player_data = player_data
		_character_manager_map[player_data] = player_battle_manager

func new_opponent(opponent_data:CharacterData):
	opponent_data = opponent_data.duplicate()
	var battle_manager : CharacterBattleManager = ai_opponents_manager.add_opponent(opponent_data)
	_character_manager_map[opponent_data] = battle_manager
	battle_manager.connect("died", self, "_on_CharacterBattleManager_died")
	battle_manager.connect("updated_status", self, "_on_CharacterBattleManager_updated_status")
	battle_opportunities_manager.add_opponent(opponent_data)
	player_interface.add_opponent(opponent_data)
	opponents.append(opponent_data)

func set_opponents(values:Array):
	for value in values:
		if value is CharacterData:
			new_opponent(value)

func start_battle():
	battle_phase_manager.advance()

func _setup_enemy_board():
	for opponent in opponents:
		battle_opportunities_manager.reset_opponent_opportunities(opponent)
	advance_phase_timer.start()

func _take_enemy_turn():
	ai_opponents_manager.opponents_take_turn(_round_opportunities_map.keys())
	advance_phase_timer.start()

func _on_hand_drawn():
	if player_interface.is_connected("drawing_completed", self, "_on_hand_drawn"):
		player_interface.disconnect("drawing_completed", self, "_on_hand_drawn")
	player_interface.mark_character_inactive(player_data)
	player_interface.start_turn()

func _start_player_turn():
	battle_opportunities_manager.reset_player_opportunities()
	player_interface.connect("drawing_completed", self, "_on_hand_drawn")
	player_interface.mark_character_active(player_data)
	advance_action_timer.start()
	yield(advance_action_timer, "timeout")
	player_battle_manager.update_start_of_turn_statuses()
	advance_action_timer.start()
	yield(advance_action_timer, "timeout")
	player_battle_manager.reset_energy()
	player_battle_manager.draw_hand()

func _end_player_turn():
	var cards_in_hand : Array = player_battle_manager.hand.cards.duplicate()
	var discarding_cards : Array = effects_manager.include_discardable_cards(cards_in_hand)
	var exhausting_cards : Array = effects_manager.include_exhaustable_cards(cards_in_hand)
	if discarding_cards.size() + exhausting_cards.size() > 0:
		player_interface.connect("discard_completed", battle_phase_manager, "advance")
		for discarding_card in discarding_cards:
			player_battle_manager.discard_card(discarding_card)
		for exhausting_card in exhausting_cards:
			player_battle_manager.exhaust_card(exhausting_card)
	else:
		battle_phase_manager.advance()

func setup_battle():
	if _skip_opening_phase:
		battle_phase_manager.advance()
	_skip_opening_phase = true
	var starting_cards : Array = player_battle_manager.draw_pile.cards.duplicate()
	var innate_cards : Array = effects_manager.include_innate_cards(starting_cards)
	if innate_cards.size() > 0:
		player_interface.connect("drawing_completed", battle_phase_manager, "advance")
		for innate_card in innate_cards:
			player_battle_manager.draw_card(innate_card)
	else:
		battle_phase_manager.advance()

func start_round():
	if player_interface.is_connected("drawing_completed", battle_phase_manager, "advance"):
		player_interface.disconnect("drawing_completed", battle_phase_manager, "advance")
	if player_interface.is_connected("discard_completed", battle_phase_manager, "advance"):
		player_interface.disconnect("discard_completed", battle_phase_manager, "advance")
	battle_opportunities_manager.reset()
	player_interface.start_round()
	advance_phase_timer.start()

func _discard_or_exhaust_card(card:CardData):
	if card.has_effect(EffectCalculator.EXHAUST_EFFECT):
		player_battle_manager.exhaust_card(card)
	else:
		player_battle_manager.discard_card(card)

func _resolve_card_played_actions(card:CardData, opportunity = null):
	if opportunity is OpportunityData:
		effects_manager.resolve_on_play_opportunity(card, opportunity, _character_manager_map)
		battle_opportunities_manager.remove_opportunity(opportunity)
	else:
		effects_manager.resolve_on_play(card, player_data, _character_manager_map)

func _resolve_character_actions(character:CharacterData):
	var opportunities : Array = battle_opportunities_manager.get_character_opportunities(character)
	for opportunity in opportunities:
		if opportunity.card_data != null:
			effects_manager.resolve_on_play_opportunity(opportunity.card_data, opportunity, _character_manager_map)
			battle_opportunities_manager.remove_opportunity(opportunity)
			player_interface.opponent_discards_card(opportunity.card_data)

func _resolve_card_drawn_actions(card:CardData):
	effects_manager.resolve_on_draw(card, player_data, _character_manager_map)

func _resolve_card_discarded_actions(card:CardData):
	effects_manager.resolve_on_discard(card, player_data, _character_manager_map)

func _clear_round_opportunities():
	player_interface.remove_all_opportunities()
	_round_opportunities_map.clear()
	battle_phase_manager.advance()

func _on_CharacterBattleManager_drew_card(card):
	player_interface.draw_card(card)
	_resolve_card_drawn_actions(card)

func _on_CharacterBattleManager_drew_card_from_draw_pile(card):
	player_interface.draw_card_from_draw_pile(card)

func _on_PlayerInterface_card_played(card):
	player_battle_manager.play_card(card)

func _on_PlayerInterface_card_played_on_opportunity(card:CardData, opportunity:OpportunityData):
	player_battle_manager.play_card_on_opportunity(card, opportunity)

func _on_PlayerInterface_ending_turn():
	_end_player_turn()

func _on_CharacterBattleManager_discarded_card(card):
	player_interface.discard_card(card)
	_resolve_card_discarded_actions(card)

func _on_CharacterBattleManager_exhausted_card(card):
	player_interface.exhaust_card(card)

func _on_CharacterBattleManager_reshuffled_card(card):
	player_interface.reshuffle_card(card)

func _on_CharacterBattleManager_played_card(card:CardData, opportunity:OpportunityData):
	player_interface.play_card(player_data, card, opportunity)
	_resolve_card_played_actions(card, opportunity)
	_discard_or_exhaust_card(card)

func _on_Opening_phase_entered():
	setup_battle()

func _on_RoundStart_phase_entered():
	start_round()

func _on_EnemySetup_phase_entered():
	_setup_enemy_board()

func _on_Enemy_phase_entered():
	_take_enemy_turn()

func _on_Player_phase_entered():
	_start_player_turn()

func _on_PlayerEndTurn_phase_entered():
	if player_interface.is_connected("discard_completed", battle_phase_manager, "advance"):
		player_interface.disconnect("discard_completed", battle_phase_manager, "advance")
	player_battle_manager.update_end_of_turn_statuses()
	battle_phase_manager.advance()

func _on_EnemyResolution_phase_entered():
	for opponent in opponents:
		if _battle_ended:
			return
		if not opponent.is_active():
			continue
		var manager : CharacterBattleManager = _character_manager_map[opponent]
		player_interface.mark_character_active(opponent)
		advance_action_timer.start()
		yield(advance_action_timer, "timeout")
		manager.update_start_of_turn_statuses()
		if not opponent.is_active():
			player_interface.mark_character_inactive(opponent)
			continue
		advance_action_timer.start()
		yield(advance_action_timer, "timeout")
		_resolve_character_actions(opponent)
		advance_action_timer.start()
		yield(advance_action_timer, "timeout")
		manager.update_end_of_turn_statuses()
		player_interface.mark_character_inactive(opponent)
		advance_character_timer.start()
		yield(advance_character_timer, "timeout")
	if _battle_ended:
		return
	battle_phase_manager.advance()

func _on_RoundEnd_phase_entered():
	_clear_round_opportunities()

func _on_AIOpponentsManager_played_card(character, card, opportunity):
	player_interface.play_card(character, card, opportunity)

func _on_AdvancePhaseTimer_timeout():
	battle_phase_manager.advance()

func _on_EffectManager_apply_health(character, health):
	if not character in _character_manager_map:
		return
	var battle_manager : CharacterBattleManager = _character_manager_map[character]
	if health < 0:
		var damage : int = -(health)
		battle_manager.take_damage(damage)
	else:
		battle_manager.gain_health(health)

func _on_EffectManager_apply_status(character, status, origin):
	if not character in _character_manager_map:
		return
	var character_manager : CharacterBattleManager = _character_manager_map[character]
	character_manager.gain_status(status, origin)

func _on_EffectManager_apply_energy(character, energy):
	if not character in _character_manager_map:
		return
	var character_manager : CharacterBattleManager = _character_manager_map[character]
	character_manager.gain_energy(energy)

func _on_EffectManager_add_opportunity(type, source, target):
	battle_opportunities_manager.add_opportunity(type, source, target)

func _count_active_opponents():
	var active_opponents : int = 0
	for opponent in opponents:
		if opponent is CharacterData:
			if opponent.is_active():
				active_opponents += 1
	return active_opponents

func _on_CharacterBattleManager_died(character):
	if character == player_data:
		_battle_ended = true
		battle_end_timer.start()
		yield(battle_end_timer, "timeout")
		emit_signal("player_lost")
	else:
		if _count_active_opponents() == 0:
			_battle_ended = true
			battle_end_timer.start()
			yield(battle_end_timer, "timeout")
			emit_signal("player_won")

func _on_BattleOpportunitiesManager_opportunity_added(opportunity:OpportunityData):
	player_interface.add_opportunity(opportunity)
	_round_opportunities_map[opportunity] = true

func _on_BattleOpportunitiesManager_opportunity_removed(opportunity:OpportunityData):
	_round_opportunities_map.erase(opportunity)
	player_interface.remove_opportunity(opportunity)

func _on_CharacterBattleManager_updated_status(character, status, delta):
	player_interface.update_status(character, status, delta)

func _on_PlayerInterface_draw_pile_pressed():
	var deck : Array = player_battle_manager.draw_pile.cards.duplicate()
	if deck.size() == 0:
		return
	deck.sort()
	emit_signal("view_deck_pressed", deck)

func _on_PlayerInterface_discard_pile_pressed():
	var deck : Array = player_battle_manager.discard_pile.cards.duplicate()
	if deck.size() == 0:
		return
	emit_signal("view_deck_pressed", deck)

func _on_PlayerInterface_exhaust_pile_pressed():
	var deck : Array = player_battle_manager.exhaust_pile.cards.duplicate()
	if deck.size() == 0:
		return
	emit_signal("view_deck_pressed", deck)

func _on_EffectManager_add_card_to_hand(card, character):
	var battle_manager : CharacterBattleManager = _character_manager_map[character]
	player_interface.new_character_card(character, card)
	player_interface.animate_playing_card(card)
	battle_manager.add_card_to_hand(card)

func _on_EffectManager_add_card_to_draw_pile(card, character):
	var battle_manager : CharacterBattleManager = _character_manager_map[character]
	player_interface.new_character_card(character, card)
	player_interface.animate_playing_card(card)
	battle_manager.add_card_to_draw_pile(card)

func _on_EffectManager_add_card_to_discard_pile(card, character):
	var battle_manager : CharacterBattleManager = _character_manager_map[character]
	player_interface.new_character_card(character, card)
	player_interface.animate_playing_card(card)
	battle_manager.add_card_to_discard_pile(card)

func _on_EffectManager_draw_from_draw_pile(character, count):
	var battle_manager : CharacterBattleManager = _character_manager_map[character]
	for _i in range(count):
		battle_manager.draw_card()

func _on_PlayerInterface_card_inspected(card):
	emit_signal("card_inspected", card)

func _on_PlayerInterface_card_forgotten(card):
	emit_signal("card_forgotten", card)

func _on_PlayerInterface_status_inspected(status_icon):
	emit_signal("status_inspected", status_icon)

func _on_PlayerInterface_status_forgotten(status_icon):
	emit_signal("status_forgotten", status_icon)
