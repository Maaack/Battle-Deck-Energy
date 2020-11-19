extends BattleManager


class_name MultiplayerBattleManager

var player_id_character_map : Dictionary = {}
var character_player_id_map : Dictionary = {}

func add_player(player_id : int, character_data : CharacterData, team : String):
	var battle_manager = add_character(character_data, team)
	character_player_id_map[character_data] = player_id
	player_id_character_map[player_id] = character_data
	battle_manager.set_network_master(player_id)

remotesync func advance_character_phase():
	print("Remote advance character phase")
	character_phase_manager.advance()

remotesync func _remote_on_card_played(card_key : String, card_player_id : int, source_player_id : int, target_player_id : int , opportunity_type : int):
	var card_player : CharacterData = player_id_character_map[card_player_id]
	var opportunity_source : CharacterData = player_id_character_map[source_player_id]
	var opportunity_target : CharacterData = player_id_character_map[target_player_id]
	var opportunity = opportunities_manager.get_matching_opportunity(opportunity_source, opportunity_target, opportunity_type)
	var card = card_library.data[card_key]
	effects_manager.resolve_on_play_opportunity(card, opportunity, _character_manager_map)
	opportunities_manager.remove_opportunity(opportunity)

remotesync func _remote_on_turn_ended(player_id : int):
	var character : CharacterData = player_id_character_map[player_id]
	emit_signal("turn_ended", character)
	
func _end_character_turn(character_data : CharacterData):
	print("Ending turn `%s`" % str(character_data))
	._end_character_turn(character_data)
	
func on_card_played(character : CharacterData, card:CardData, opportunity:OpportunityData):
	.on_card_played(character, card, opportunity)
	emit_signal("card_played", character, card, opportunity)
	_discard_or_exhaust_card(character, card)

func _on_CharacterBattleManager_card_played(character : CharacterData, card:CardData, opportunity:OpportunityData):
	var card_player_id : int = character_player_id_map[character]
	var source_player_id : int = character_player_id_map[opportunity.source]
	var target_player_id : int = character_player_id_map[opportunity.target]
	rpc('_remote_on_card_played', card.title, card_player_id, source_player_id, target_player_id, opportunity.type)

func _on_CharacterBattleManager_turn_ended(character : CharacterData):
	var player_id : int = character_player_id_map[character]
	rpc('_remote_on_turn_ended', player_id)
	if character == active_character:
		rpc('advance_character_phase')

