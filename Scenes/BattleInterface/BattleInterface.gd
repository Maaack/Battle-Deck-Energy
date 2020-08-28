extends Control


signal player_won
signal player_lost

onready var player_interface = $PlayerInterface
onready var player_battle_manager = $CharacterBattleManager
onready var ai_opponents_manager = $AIOpponentsManager
onready var battle_phase_manager = $BattlePhaseManager
onready var battle_opportunities_manager = $BattleOpportunitiesManager
onready var effects_manager = $EffectManager
onready var advance_phase_timer = $AdvancePhaseTimer

var player_data : CharacterData setget set_player_data
var opponents : Array = [] setget set_opponents

var _character_manager_map : Dictionary = {}
var _round_opportunities_map : Dictionary = {}

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
	battle_manager.connect("gained_energy", self, "_on_CharacterBattleManager_gained_energy")
	battle_manager.connect("gained_health", self, "_on_CharacterBattleManager_gained_health")
	battle_manager.connect("lost_energy", self, "_on_CharacterBattleManager_lost_energy")
	battle_manager.connect("lost_health", self, "_on_CharacterBattleManager_lost_health")
	battle_manager.connect("died", self, "_on_CharacterBattleManager_died")
	battle_opportunities_manager.add_opponent(opponent_data)
	player_interface.add_opponent(opponent_data)

func set_opponents(values:Array):
	for value in values:
		if value is CharacterData:
			new_opponent(value)

func start_battle():
	battle_phase_manager.advance()

func _setup_enemy_board():
	battle_opportunities_manager.reset_all_opponent_opportunities()
	advance_phase_timer.start()

func _take_enemy_turn():
	ai_opponents_manager.opponents_take_turn(_round_opportunities_map.keys())
	advance_phase_timer.start()

func _on_hand_drawn():
	if player_interface.is_connected("drawing_completed", self, "_on_hand_drawn"):
		player_interface.disconnect("drawing_completed", self, "_on_hand_drawn")
	player_battle_manager.reset_energy()
	player_interface.start_turn()

func _setup_player_board():
	battle_opportunities_manager.reset_player_opportunities()

func _start_player_turn():
	_setup_player_board()
	player_interface.connect("drawing_completed", self, "_on_hand_drawn")
	player_battle_manager.draw_hand()

func _end_player_turn():
	player_interface.connect("discard_completed",  battle_phase_manager, "advance")
	var discarded_cards : Array = player_battle_manager.discard_hand()
	if discarded_cards.size() == 0:
		battle_phase_manager.advance()

func start_round():
	if player_interface.is_connected("discard_completed", battle_phase_manager, "advance"):
		player_interface.disconnect("discard_completed", battle_phase_manager, "advance")
	battle_opportunities_manager.reset()
	player_interface.start_round()
	advance_phase_timer.start()

func _discard_played_cards():
	var discarding_flag = false
	for opp_data in _round_opportunities_map:
		if opp_data is OpportunityData and is_instance_valid(opp_data.card_data):
			if opp_data.source == player_data:
				discarding_flag = true
				player_battle_manager.discard_card(opp_data.card_data)
			else:
				player_interface.opponent_discards_card(opp_data.card_data)
	return discarding_flag

func _resolve_actions():
	if player_interface.is_connected("discard_completed", battle_phase_manager, "advance"):
		player_interface.disconnect("discard_completed", battle_phase_manager, "advance")
	var target_effects : Dictionary = effects_manager.get_target_effects(_round_opportunities_map.keys())
	for target in target_effects:
		effects_manager.resolve_effects(target, target_effects[target])
	var discarding_flag = _discard_played_cards()
	player_interface.remove_all_openings()
	_round_opportunities_map.clear()
	if discarding_flag:
		player_interface.connect("discard_completed",  battle_phase_manager, "advance")
	else:
		battle_phase_manager.advance()

func _resolve_immediate_actions(card:CardData, opportunity:OpportunityData):
	if card.type_tag == battle_opportunities_manager.PARRY_TYPE:
		battle_opportunities_manager.add_attack_opportunity(opportunity.source, opportunity.target)

func _on_CharacterBattleManager_drew_card(card):
	player_interface.draw_card(card)

func _on_PlayerInterface_card_played_on_opportunity(card:CardData, opportunity:OpportunityData):
	player_battle_manager.play_card(card, opportunity)
	_resolve_immediate_actions(card, opportunity)

func _on_PlayerInterface_ending_turn():
	_end_player_turn()

func _on_CharacterBattleManager_discarded_card(card):
	player_interface.discard_card(card)

func _on_CharacterBattleManager_reshuffled_card(card):
	player_interface.reshuffle_card(card)

func _on_CharacterBattleManager_played_card(card:CardData, opportunity:OpportunityData):
	player_interface.play_card(player_data, card, opportunity)

func _on_Opening_phase_entered():
	start_round()

func _on_EnemySetup_phase_entered():
	_setup_enemy_board()

func _on_Enemy_phase_entered():
	_take_enemy_turn()

func _on_Player_phase_entered():
	_start_player_turn()

func _on_Resolution_phase_entered():
	_resolve_actions()

func _on_AIOpponentsManager_played_card(character, card, opportunity):
	player_interface.play_card(character, card, opportunity)

func _on_AdvancePhaseTimer_timeout():
	battle_phase_manager.advance()

func _on_EffectManager_damage_character(character:CharacterData, damage:int):
	if not character in _character_manager_map:
		return
	var battle_manager : CharacterBattleManager = _character_manager_map[character]
	battle_manager.lose_health(damage)

func _on_CharacterBattleManager_gained_energy(character:CharacterData, amount:int):
	player_interface.character_gains_energy(character, amount)

func _on_CharacterBattleManager_gained_health(character:CharacterData, amount:int):
	player_interface.character_gains_health(character, amount)

func _on_CharacterBattleManager_lost_energy(character:CharacterData, amount:int):
	player_interface.character_loses_energy(character, amount)

func _on_CharacterBattleManager_lost_health(character:CharacterData, amount:int):
	player_interface.character_loses_health(character, amount)

func _count_active_opponents():
	var active_opponents : int = 0
	for opponent in opponents:
		if opponent is CharacterData:
			if opponent.is_active():
				active_opponents += 1
	return active_opponents

func _on_CharacterBattleManager_died(character):
	player_interface.character_dies(character)
	if character == player_data:
		emit_signal("player_lost")
	else:
		if _count_active_opponents() == 0:
			emit_signal("player_won")

func _on_BattleOpportunitiesManager_opportunity_added(opportunity:OpportunityData):
	var opening : BattleOpening = player_interface.add_opening(opportunity)
	if is_instance_valid(opening):
		_round_opportunities_map[opening.opportunity_data] = opening
