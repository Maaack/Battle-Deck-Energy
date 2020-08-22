extends Control


onready var player_interface = $PlayerInterface
onready var player_battle_manager = $CharacterBattleManager
onready var ai_opponents_manager = $AIOpponentsManager
onready var battle_phase_manager = $BattlePhaseManager
onready var battle_opps_manager = $BattleOpportunitiesManager

var player_data : CharacterData setget set_player_data
var opponents : Array = [] setget set_opponents

var _round_opportunities_map : Dictionary = {}

func set_player_data(value:CharacterData):
	player_data = value
	if is_instance_valid(player_data):
		player_interface.player_data = player_data
		player_battle_manager.character_data = player_data
		battle_opps_manager.player_data = player_data

func new_opponent(opponent_data:CharacterData):
	opponent_data = opponent_data.duplicate()
	ai_opponents_manager.add_opponent(opponent_data)
	battle_opps_manager.add_opponent(opponent_data)
	player_interface.add_opponent_actions(opponent_data)

func set_opponents(values:Array):
	for value in values:
		if value is CharacterData:
			new_opponent(value)

func _on_Opening_card_assigned(opp_data:OpportunityData, card_data:CardData):
	opp_data.card_data = card_data

func start_battle():
	battle_phase_manager.advance()

func _take_enemy_turn():
	var opportunities : Array = battle_opps_manager.get_all_opponent_opportunities()
	var openings : Array = player_interface.add_opponent_openings(opportunities)
	ai_opponents_manager.opponents_take_turn()
	battle_phase_manager.advance()

func _on_hand_drawn():
	if player_interface.is_connected("drawing_completed", self, "_on_hand_drawn"):
		player_interface.disconnect("drawing_completed", self, "_on_hand_drawn")
	player_battle_manager.reset_energy()
	player_interface.start_turn()

func _start_player_turn():
	player_interface.connect("drawing_completed", self, "_on_hand_drawn")
	var opportunities : Array = battle_opps_manager.get_player_opportunities()
	var openings : Array = player_interface.add_player_openings(opportunities)
	for opening in openings:
		if opening is BattleOpening:
			_round_opportunities_map[opening.opportunity_data] = opening
			opening.connect("card_assigned", self, "_on_Opening_card_assigned")
	player_battle_manager.draw_hand()

func _end_player_turn():
	player_interface.connect("discard_completed",  battle_phase_manager, "advance")
	var discarded_cards : Array = player_battle_manager.discard_hand()
	if discarded_cards.size() == 0:
		battle_phase_manager.advance()

func start_round():
	if player_interface.is_connected("discard_completed", battle_phase_manager, "advance"):
		player_interface.disconnect("discard_completed", battle_phase_manager, "advance")
	player_interface.start_round()
	battle_phase_manager.advance()

func _resolve_actions():
	var discarding_flag = false
	for opp_data in _round_opportunities_map:
		if opp_data is OpportunityData and is_instance_valid(opp_data.card_data):
			if opp_data.source == player_data:
				if not discarding_flag:
					discarding_flag = true
					player_interface.connect("discard_completed",  battle_phase_manager, "advance")
				player_battle_manager.discard_card(opp_data.card_data)
	player_interface.remove_all_openings()
	_round_opportunities_map.clear()
	if not discarding_flag:
		battle_phase_manager.advance()

func _on_CharacterBattleManager_drew_card(card):
	player_interface.draw_card(card)

func _on_PlayerInterface_card_dropped_on_opening(card_data, battle_opening):
	player_battle_manager.play_card(card_data, battle_opening)

func _on_PlayerInterface_ending_turn():
	_end_player_turn()

func _on_CharacterBattleManager_discarded_card(card):
	player_interface.discard_card(card)

func _on_CharacterBattleManager_reshuffled_card(card):
	player_interface.reshuffle_card(card)

func _on_CharacterBattleManager_played_card(card, battle_opening):
	player_interface.play_card(card, battle_opening)

func _on_CharacterBattleManager_changed_energy(energy, max_energy):
	player_interface.set_energy_meter(energy, max_energy)

func _on_Opening_phase_entered():
	start_round()

func _on_Enemy_phase_entered():
	_take_enemy_turn()

func _on_Player_phase_entered():
	_start_player_turn()

func _on_Resolution_phase_entered():
	_resolve_actions()

