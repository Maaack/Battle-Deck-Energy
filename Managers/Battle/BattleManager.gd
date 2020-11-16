extends Node


class_name BattleManager

signal card_drawn(character, card)
signal card_added_to_hand(character, card)
signal card_removed_from_hand(character, card)
signal card_discarded(character, card)
signal card_exhausted(character, card)
signal card_reshuffled(character, card)
signal card_played(character, card, opportunity)
signal status_updated(character, status, delta)
signal character_died(character)
signal active_character_updated(character)
signal active_team_updated(team)
signal before_hand_discarded(character)
signal before_hand_drawn(character)
signal turn_started(character)
signal team_lost(team)
signal team_won(team)
signal opportunity_added(opportunity)
signal opportunity_removed(opportunity)
signal opportunities_reset

onready var advance_phase_timer = $AdvancePhaseTimer
onready var advance_character_timer = $AdvanceCharacterTimer
onready var advance_action_timer = $AdvanceActionTimer
onready var battle_phase_manager = $BattlePhaseManager
onready var team_phase_manager = $TeamPhaseManager
onready var character_phase_manager = $CharacterPhaseManager
onready var opportunities_manager = $OpportunitiesManager
onready var effects_manager = $EffectManager
onready var team_manager = $TeamManager

var card_library : CommonData = preload("res://Resources/Common/CardLibrary.tres")
var character_battle_manager_scene = load("res://Managers/NewCharacterBattle/NewCharacterBattleManager.tscn")
var _character_manager_map : Dictionary = {}
var _skip_battle_setup : bool = false
var _battle_ended : bool = false
var teams_in_play : Array = []
var active_character
var active_team

func get_character_manager_instance():
	return character_battle_manager_scene.instance()

func add_team(team : String):
	if not team in teams_in_play:
		teams_in_play.append(team)
		var team_phase_instance : Phase = team_phase_manager.add_phase(team)
		team_phase_instance.connect("phase_entered", self, "_on_Team_phase_entered", [team])

func add_character(character_data : CharacterData, team : String):
	if character_data in _character_manager_map:
		return
	var battle_manager = get_character_manager_instance()
	battle_manager.name = character_data.nickname + 'CharacterBattleManager'
	add_child(battle_manager)
	battle_manager.character_data = character_data
	battle_manager.connect("card_added_to_hand", self, "_on_CharacterBattleManager_card_added_to_hand")
	battle_manager.connect("card_discarded", self, "_on_CharacterBattleManager_card_discarded")
	battle_manager.connect("card_drawn", self, "_on_CharacterBattleManager_card_drawn")
	battle_manager.connect("card_exhausted", self, "_on_CharacterBattleManager_card_exhausted")
	battle_manager.connect("card_played", self, "_on_CharacterBattleManager_card_played")
	battle_manager.connect("card_removed_from_hand", self, "_on_CharacterBattleManager_card_removed_from_hand")
	battle_manager.connect("card_reshuffled", self, "_on_CharacterBattleManager_card_reshuffled")
	battle_manager.connect("character_died", self, "_on_CharacterBattleManager_character_died")
	battle_manager.connect("status_updated", self, "_on_CharacterBattleManager_status_updated")
	add_team(team)
	_character_manager_map[character_data] = battle_manager
	team_manager.add_character(character_data, team)
	return battle_manager

func get_character_manager(character_data : CharacterData):
	if character_data in _character_manager_map:
		return _character_manager_map[character_data]

func get_all_characters():
	return _character_manager_map.keys()

func _set_active_character(character_data : CharacterData):
	if active_character != character_data:
		active_character = character_data
		emit_signal("active_character_updated")
	var team : String = team_manager.get_team(character_data)
	if active_team != team:
		active_team = team
		emit_signal("active_team_updated")

func start_battle():
	battle_phase_manager.advance()

func _setup_opportunities(character_data : CharacterData):
	var enemies_list = team_manager.get_enemies(character_data)
	for enemy in enemies_list: 
		if not enemy.is_alive():
			continue
		opportunities_manager.add_opportunity(CardData.CardType.ATTACK, character_data, enemy)
	opportunities_manager.add_opportunity(CardData.CardType.DEFEND, character_data, character_data)
	opportunities_manager.add_opportunity(CardData.CardType.SKILL, character_data, character_data)

func _start_character_turn(character_data : CharacterData):
	_set_active_character(character_data)
	_setup_opportunities(character_data)
	advance_action_timer.start()
	yield(advance_action_timer, "timeout")
	character_phase_manager.advance()

func _active_character_draws():
	var character_manager = _character_manager_map[active_character]
	character_manager.update_early_start_of_turn_statuses()
	character_manager.update_late_start_of_turn_statuses()
	advance_action_timer.start()
	yield(advance_action_timer, "timeout")
	character_manager.reset_energy()
	emit_signal("before_hand_drawn", active_character)
	character_manager.draw_hand()

func _end_character_turn(character_data : CharacterData):
	var character_manager : NewCharacterBattleManager = _character_manager_map[character_data]
	character_manager.update_end_of_turn_statuses()
	if character_manager.has_discardable_cards_in_hand():
		emit_signal("before_hand_discarded", character_data)
		character_manager.discard_hand()
	else:
		character_phase_manager.advance()

func setup_battle():
	if _skip_battle_setup:
		battle_phase_manager.advance()
		return
	_skip_battle_setup = true
	for character_manager in _character_manager_map.values():
		if character_manager.has_innate_cards_in_draw_pile():
			character_manager.draw_innate_cards()
	battle_phase_manager.advance()

func start_round():
	opportunities_manager.reset()
	advance_phase_timer.start()

remotesync func advance_character_phase():
	character_phase_manager.advance()

func _discard_or_exhaust_card(character:CharacterData, card:CardData):
	var character_battle_manager : NewCharacterBattleManager = _character_manager_map[character]
	if card.has_effect(EffectCalculator.EXHAUST_EFFECT):
		character_battle_manager.exhaust_card(card)
	else:
		character_battle_manager.discard_card(card)

func _resolve_card_drawn_actions(character : CharacterData, card : CardData):
	effects_manager.resolve_on_draw(card, character, _character_manager_map)

func _resolve_card_discarded_actions(character : CharacterData, card : CardData):
	effects_manager.resolve_on_discard(card, character, _character_manager_map)

func _on_CharacterBattleManager_card_added_to_hand(character : CharacterData, card : CardData):
	emit_signal("card_added_to_hand", character, card)

func _on_CharacterBattleManager_card_removed_from_hand(character : CharacterData, card : CardData):
	emit_signal("card_removed_from_hand", character, card)

func _on_CharacterBattleManager_card_drawn(character : CharacterData, card : CardData):
	emit_signal("card_drawn", character, card)
	_resolve_card_drawn_actions(character, card)

func _on_CharacterBattleManager_card_discarded(character : CharacterData, card : CardData):
	emit_signal("card_discarded", character, card)
	_resolve_card_discarded_actions(character, card)

func _on_CharacterBattleManager_card_exhausted(character : CharacterData, card : CardData):
	emit_signal("card_exhausted", character, card)

func _on_CharacterBattleManager_card_reshuffled(character : CharacterData, card : CardData):
	emit_signal("card_reshuffled", character, card)

func on_card_played(character : CharacterData, card:CardData, opportunity:OpportunityData):
	var character_battle_manager : NewCharacterBattleManager = _character_manager_map[character]
	character_battle_manager.play_card_on_opportunity(card, opportunity)
	rpc('_remote_on_card_played', card.title, opportunity.source.nickname, opportunity.target.nickname, opportunity.type)
	opportunities_manager.remove_opportunity(opportunity)
	_discard_or_exhaust_card(character, card)

remotesync func _remote_on_card_played(card_key : String, opportunity_source : String, opportunity_target : String , opportunity_type : int):
	var opportunity = opportunities_manager.get_matching_opportunity(opportunity_source, opportunity_target, opportunity_type)
	var card = card_library.data[card_key]
	effects_manager.resolve_on_play_opportunity(card, opportunity, _character_manager_map)

func _on_CharacterBattleManager_card_played(character : CharacterData, card:CardData, opportunity:OpportunityData):
	emit_signal("card_played", character, card, opportunity)

func _on_CharacterBattleManager_status_updated(character : CharacterData, status, delta):
	emit_signal("status_updated", character, status, delta)

func _on_CharacterBattleManager_character_died(character):
	if _battle_ended:
		return
	emit_signal("character_died", character)
	var allies_list = team_manager.get_allies(character)
	var ally_alive = false
	for ally_character in allies_list:
		if ally_character.is_alive():
			ally_alive = true
			break
	if not ally_alive:
		var team : String = team_manager.get_team(character)
		teams_in_play.erase(team)
		emit_signal("team_lost", team)
	if teams_in_play.size() == 1:
		_battle_ended = true
		var winning_team : String = teams_in_play[0]
		emit_signal("team_won", winning_team)

func _on_Team_phase_entered(team : String):
	var team_list : Array = team_manager.get_team_list(team)
	for character in team_list:
		if not character is CharacterData:
			continue
		if not character.is_alive():
			continue
		_set_active_character(character)
		_start_character_turn(character)
		return
	team_phase_manager.advance()

func _on_DrawingCards_phase_entered():
	_active_character_draws()

func _on_BattleStart_phase_entered():
	setup_battle()

func _on_RoundStart_phase_entered():
	start_round()

func _on_RoundEnd_phase_entered():
	battle_phase_manager.advance()

func _on_TeamStart_phase_entered():
	battle_phase_manager.advance()

func _on_TeamPhase_phase_entered():
	team_phase_manager.advance()

func _on_CharacterStart_phase_entered():
	var active_team_list : Array = team_manager.get_team_list(active_team)
	var active_player_index : int = active_team_list.find(active_character)
	if active_player_index < active_team_list.size() - 1:
		active_character = active_team_list[active_player_index + 1]
		advance_character_phase()
	else:
		team_phase_manager.advance()

func _on_AdvancePhaseTimer_timeout():
	battle_phase_manager.advance()

func _on_EffectManager_apply_health(character, health):
	if not character in _character_manager_map:
		return
	var character_manager : NewCharacterBattleManager = _character_manager_map[character]
	if health < 0:
		var damage : int = -(health)
		character_manager.take_damage(damage)
	else:
		character_manager.gain_health(health)

func _on_EffectManager_apply_status(character, status, origin):
	if not character in _character_manager_map:
		return
	var character_manager : NewCharacterBattleManager = _character_manager_map[character]
	character_manager.gain_status(status, origin)

func _on_EffectManager_apply_energy(character, energy):
	if not character in _character_manager_map:
		return
	var character_manager : NewCharacterBattleManager = _character_manager_map[character]
	character_manager.gain_energy(energy)

func _on_EffectManager_add_opportunity(type, source, target):
	opportunities_manager.add_opportunity(type, source, target)

func _on_EffectManager_add_card_to_hand(card, character):
	var battle_manager : NewCharacterBattleManager = _character_manager_map[character]
	battle_manager.add_card_to_hand(card)

func _on_EffectManager_add_card_to_draw_pile(card, character):
	var battle_manager : NewCharacterBattleManager = _character_manager_map[character]
	battle_manager.add_card_to_draw_pile(card)

func _on_EffectManager_add_card_to_discard_pile(card, character):
	var battle_manager : NewCharacterBattleManager = _character_manager_map[character]
	battle_manager.add_card_to_discard_pile(card)

func _on_EffectManager_draw_from_draw_pile(character, count):
	var battle_manager : NewCharacterBattleManager = _character_manager_map[character]
	for _i in range(count):
		battle_manager.draw_card()

func _on_OpportunitiesManager_opportunity_added(opportunity):
	emit_signal("opportunity_added", opportunity)

func _on_OpportunitiesManager_opportunity_removed(opportunity):
	emit_signal("opportunity_removed", opportunity)

func _on_OpportunitiesManager_opportunities_reset():
	emit_signal("opportunities_reset")

func _on_Playing_phase_entered():
	emit_signal("turn_started", active_character)

func _on_DiscardingCards_phase_entered():
	_end_character_turn(active_character)
