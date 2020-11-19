extends Node


class_name BattleManager

signal card_drawn(character, card)
signal card_added_to_hand(character, card)
signal card_removed_from_hand(character, card)
signal card_discarded(character, card)
signal card_exhausted(character, card)
signal card_reshuffled(character, card)
signal card_revealed(character, card)
signal card_played(character, card, opportunity)
signal card_spawned(character, card)
signal status_updated(character, status, delta)
signal character_died(character)
signal active_character_updated(character)
signal active_team_updated(team)
signal before_hand_discarded(character)
signal before_hand_drawn(character)
signal turn_started(character)
signal turn_ended(character)
signal team_lost(team)
signal team_won(team)
signal opportunity_added(opportunity)
signal opportunity_removed(opportunity)
signal opportunities_reset

onready var advance_phase_timer : Timer = $AdvancePhaseTimer
onready var advance_action_timer : Timer = $AdvanceActionTimer
onready var battle_phase_manager : PhaseManager = $BattlePhaseManager
onready var team_phase_manager : PhaseManager = $TeamPhaseManager
onready var character_phase_manager : PhaseManager = $CharacterPhaseManager
onready var opportunities_manager : OpportunitiesManager = $OpportunitiesManager
onready var effects_manager : EffectsManager = $EffectManager
onready var team_manager : TeamManager = $TeamManager

var card_library : CommonData = preload("res://Resources/Common/CardLibrary.tres")
var character_battle_manager_scene = load("res://Managers/CharacterBattle/CharacterBattleManager.tscn")
var _character_manager_map : Dictionary = {}
var _skip_battle_setup : bool = false
var _battle_ended : bool = false
var teams_in_play : Array = []
var active_character
var active_team

func _new_character_manager_instance(character_data : CharacterData, team : String):
	var character_battle_manager : CharacterBattleManager = character_battle_manager_scene.instance()
	_character_manager_map[character_data] = character_battle_manager
	return character_battle_manager

func add_team(team : String):
	if not team in teams_in_play:
		teams_in_play.append(team)
		var team_phase_instance : Phase = team_phase_manager.add_phase(team)
		team_phase_instance.connect("phase_entered", self, "_on_Team_phase_entered", [team])

func _connect_character_battle_manager(character_battle_manager : CharacterBattleManager):
	character_battle_manager.connect("card_added_to_hand", self, "_on_CharacterBattleManager_card_added_to_hand")
	character_battle_manager.connect("card_discarded", self, "_on_CharacterBattleManager_card_discarded")
	character_battle_manager.connect("card_drawn", self, "_on_CharacterBattleManager_card_drawn")
	character_battle_manager.connect("card_exhausted", self, "_on_CharacterBattleManager_card_exhausted")
	character_battle_manager.connect("card_played", self, "_on_CharacterBattleManager_card_played")
	character_battle_manager.connect("card_removed_from_hand", self, "_on_CharacterBattleManager_card_removed_from_hand")
	character_battle_manager.connect("card_reshuffled", self, "_on_CharacterBattleManager_card_reshuffled")
	character_battle_manager.connect("character_died", self, "_on_CharacterBattleManager_character_died")
	character_battle_manager.connect("status_updated", self, "_on_CharacterBattleManager_status_updated")
	character_battle_manager.connect("turn_ended", self, "_on_CharacterBattleManager_turn_ended")

func add_character(character_data : CharacterData, team : String):
	if character_data in _character_manager_map:
		return
	add_team(team)
	team_manager.add_character(character_data, team)
	var character_battle_manager = _new_character_manager_instance(character_data, team)
	character_battle_manager.name = character_data.nickname + 'CharacterBattleManager'
	character_battle_manager.character_data = character_data
	add_child(character_battle_manager)
	character_battle_manager.reset()
	_connect_character_battle_manager(character_battle_manager)
	return character_battle_manager

func get_character_manager(character_data : CharacterData):
	if character_data in _character_manager_map:
		return _character_manager_map[character_data]

func get_all_characters():
	return _character_manager_map.keys()

func get_team(character_data : CharacterData):
	return team_manager.get_team(character_data)

func _set_active_character(character_data : CharacterData):
	if active_character != character_data:
		active_character = character_data
		emit_signal("active_character_updated", character_data)
	var team : String = team_manager.get_team(character_data)
	if active_team != team:
		active_team = team
		emit_signal("active_team_updated", active_team)

func start_battle():
	battle_phase_manager.advance()

func _setup_opportunities(character_data : CharacterData):
	var enemies_list = team_manager.get_enemies(character_data)
	print("%s and enemies : %s" % [character_data.nickname, enemies_list] )
	for enemy in enemies_list: 
		if not enemy.is_alive():
			continue
		opportunities_manager.add_opportunity(CardData.CardType.ATTACK, character_data, enemy)
	opportunities_manager.add_opportunity(CardData.CardType.DEFEND, character_data, character_data)
	opportunities_manager.add_opportunity(CardData.CardType.SKILL, character_data, character_data)

func get_opportunities():
	return opportunities_manager.opportunities

func _start_character_turn(character_data : CharacterData):
	_set_active_character(character_data)
	opportunities_manager.reset()
	_setup_opportunities(character_data)
	advance_action_timer.start()
	yield(advance_action_timer, "timeout")
	character_phase_manager.advance()

func _active_character_draws():
	var character_manager = _character_manager_map[active_character]
	if character_manager.has_statuses():
		character_manager.update_early_start_of_turn_statuses()
		character_manager.update_late_start_of_turn_statuses()
		advance_action_timer.start()
		yield(advance_action_timer, "timeout")
	character_manager.reset_energy()
	emit_signal("before_hand_drawn", active_character)
	character_manager.draw_hand()

func _end_character_turn(character_data : CharacterData):
	var character_manager : CharacterBattleManager = _character_manager_map[character_data]
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
	advance_phase_timer.start()

func advance_character_phase():
	character_phase_manager.advance()

func _discard_or_exhaust_card(character:CharacterData, card:CardData):
	var character_battle_manager : CharacterBattleManager = _character_manager_map[character]
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
	var character_battle_manager : CharacterBattleManager = _character_manager_map[character]
	character_battle_manager.play_card_on_opportunity(card, opportunity)

func _on_CharacterBattleManager_card_played(character : CharacterData, card:CardData, opportunity:OpportunityData):
	print("`%s` played `%s` on `%s`" % [str(character.nickname), str(card.title), str(opportunity.target.nickname)])
	emit_signal("card_played", character, card, opportunity)
	effects_manager.resolve_on_play_opportunity(card, opportunity, _character_manager_map)
	opportunities_manager.remove_opportunity(opportunity)
	_discard_or_exhaust_card(character, card)
	
func _on_CharacterBattleManager_card_revealed(character : CharacterData, card : CardData, opportunity : OpportunityData):
	emit_signal("card_revealed", character, card, opportunity)

func on_ending_turn(character : CharacterData):
	var character_battle_manager : CharacterBattleManager = _character_manager_map[character]
	character_battle_manager.end_turn()

func _on_CharacterBattleManager_turn_ended(character : CharacterData):
	emit_signal("turn_ended", character)
	if character == active_character:
		advance_character_phase()

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

func get_next_team_member():
	var active_team_list : Array = team_manager.get_team_list(active_team)
	var active_player_index : int = active_team_list.find(active_character)
	while(active_player_index < active_team_list.size() - 1):
		active_player_index += 1
		var next_character : CharacterData = active_team_list[active_player_index]
		if next_character.is_alive():
			return next_character

func start_next_member_or_team():
	var next_character = get_next_team_member()
	if next_character != null:
		_set_active_character(next_character)
		_start_character_turn(next_character)
	else:
		team_phase_manager.advance()

func _on_Team_phase_entered(team : String):
	active_team = team
	emit_signal("active_team_updated", active_team)
	start_next_member_or_team()

func _on_DrawingCards_phase_entered():
	_active_character_draws()

func _on_BattleStart_phase_entered():
	setup_battle()

func _on_RoundStart_phase_entered():
	advance_phase_timer.start()

func _on_RoundEnd_phase_entered():
	battle_phase_manager.advance()

func _on_TeamStart_phase_entered():
	battle_phase_manager.advance()

func _on_TeamPhase_phase_entered():
	team_phase_manager.advance()

func _on_CharacterStart_phase_entered():
	start_next_member_or_team()

func _on_AdvancePhaseTimer_timeout():
	battle_phase_manager.advance()

func _on_EffectManager_apply_health(character, health):
	if not character in _character_manager_map:
		return
	var character_manager : CharacterBattleManager = _character_manager_map[character]
	if health < 0:
		var damage : int = -(health)
		character_manager.take_damage(damage)
	else:
		character_manager.gain_health(health)

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
	opportunities_manager.add_opportunity(type, source, target)

func _on_EffectManager_add_card_to_hand(card, character):
	var battle_manager : CharacterBattleManager = _character_manager_map[character]
	battle_manager.add_card_to_hand(card)

func _on_EffectManager_add_card_to_draw_pile(card, character):
	var battle_manager : CharacterBattleManager = _character_manager_map[character]
	battle_manager.add_card_to_draw_pile(card)

func _on_EffectManager_add_card_to_discard_pile(card, character):
	var battle_manager : CharacterBattleManager = _character_manager_map[character]
	battle_manager.add_card_to_discard_pile(card)

func _on_EffectManager_draw_from_draw_pile(character, count):
	var battle_manager : CharacterBattleManager = _character_manager_map[character]
	for _i in range(count):
		battle_manager.draw_card()

func _on_EffectManager_spawn_card(card, character):
	emit_signal("card_spawned", character, card)

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
